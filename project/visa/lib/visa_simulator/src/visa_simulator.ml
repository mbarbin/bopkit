open! Core
open Or_error.Let_syntax
module Code = Code
module Execution_stack = Execution_stack
module Memory = Memory

module Config = struct
  type t =
    { sleep : bool
    ; stop_after_n_outputs : int option
    ; initial_memory : string option
    }
  [@@deriving sexp_of]

  let create ?(sleep = true) ?stop_after_n_outputs ?initial_memory () =
    { sleep; stop_after_n_outputs; initial_memory }
  ;;

  let default = create ()

  let param =
    let open Command.Let_syntax in
    let%map_open sleep =
      flag
        "sleep"
        (optional_with_default true bool)
        ~doc:"BOOL whether to wait for sleep instruction or skip (default true)"
    and stop_after_n_outputs =
      flag
        "stop-after-n-outputs"
        (optional int)
        ~doc:"N stop after N outputs have been produced (default run forever)"
    and initial_memory =
      flag "initial-memory" (optional string) ~doc:"FILE load initial memory contents"
    in
    { sleep; stop_after_n_outputs; initial_memory }
  ;;
end

type t =
  { error_log : Error_log.t
  ; environment : Visa_assembler.Environment.t
  ; code : Code.t
  ; execution_stack : Execution_stack.t
  ; memory : Memory.t
  ; config : Config.t
  }
[@@deriving sexp_of]

let create ~(config : Config.t) ~error_log ~program =
  let environment, assembly_constructs =
    Visa_assembler.build_environment ~error_log ~program
  in
  let%map () = Error_log.checkpoint error_log in
  let code = Code.of_assembly_constructs ~assembly_constructs in
  let execution_stack = Execution_stack.create () in
  let memory = Memory.create () in
  Option.iter config.initial_memory ~f:(fun filename ->
    let content =
      try Bit_matrix.of_text_file ~dimx:256 ~dimy:8 ~filename with
      | e ->
        Error_log.raise
          error_log
          ~loc:(Loc.in_file ~filename)
          [ Pp.text "Invalid memory file"; Pp.text (Exn.to_string e) ]
    in
    Memory.load_initial_memory memory content);
  { error_log; environment; code; execution_stack; memory; config }
;;

let rec increment_code_pointer (t : t) =
  match Stack.top t.execution_stack.macro_frames with
  | None ->
    let code_pointer = t.execution_stack.code_pointer in
    if code_pointer >= Array.length t.code.statements - 1
    then false
    else (
      t.execution_stack.code_pointer <- code_pointer + 1;
      true)
  | Some
      ({ macro_name = _; bindings = _; assembly_instructions; macro_code_pointer } as
       macro_call) ->
    if macro_code_pointer >= Array.length assembly_instructions - 1
    then (
      ignore
        (Stack.pop_exn t.execution_stack.macro_frames : Execution_stack.Macro_frame.t);
      increment_code_pointer t)
    else (
      macro_call.macro_code_pointer <- macro_code_pointer + 1;
      true)
;;

let execute_instruction t ~instruction =
  match (instruction : Visa.Label.t Visa.Instruction.t) with
  | Nop -> return (increment_code_pointer t)
  | Add ->
    Memory.add t.memory;
    return (increment_code_pointer t)
  | And ->
    Memory.and_ t.memory;
    return (increment_code_pointer t)
  | Swc ->
    Memory.switch t.memory;
    return (increment_code_pointer t)
  | Cmp ->
    Memory.cmp t.memory;
    return (increment_code_pointer t)
  | Not { register_name } ->
    Memory.not_ t.memory ~register_name;
    return (increment_code_pointer t)
  | Gof ->
    (* CR mbarbin: Gof is not used in the calendar, and implemented as Nop in
       the simulator. It's supposed to set R1 with the overflow_flag of the last
       register operation, that is set R1 to 1 iif [Add] produced a carry. *)
    return (increment_code_pointer t)
  | (Jmp { label } | Jmn { label } | Jmz { label }) as jump_instruction ->
    let%bind code_pointer =
      match Map.find t.code.labels_resolution label with
      | Some statement_index -> return statement_index
      | None -> Or_error.error_s [%sexp "Label not found", { label : Visa.Label.t }]
    in
    if match jump_instruction with
       | Jmp _ -> true
       | Jmn _ -> Memory.register_value t.memory ~register_name:R1 <> 0
       | Jmz _ -> Memory.register_value t.memory ~register_name:R1 = 0
       | _ -> assert false
    then (
      Stack.clear t.execution_stack.macro_frames;
      t.execution_stack.code_pointer <- code_pointer;
      return true)
    else return (increment_code_pointer t)
  | Store { register_name; address } ->
    let%bind () = Memory.store t.memory ~register_name ~address in
    return (increment_code_pointer t)
  | Write { register_name; address } ->
    let%bind () = Memory.write t.memory ~register_name ~address in
    return (increment_code_pointer t)
  | Load_address { address; register_name } ->
    Memory.load t.memory ~address ~register_name;
    return (increment_code_pointer t)
  | Load_value { value; register_name } ->
    Memory.load_value t.memory ~value ~register_name;
    return (increment_code_pointer t)
  | Sleep -> return (increment_code_pointer t)
;;

module Step_result = struct
  type t =
    | Macro_call of { macro_name : Visa.Macro_name.t With_loc.t }
    | Executed of
        { instruction : Visa.Label.t Visa.Instruction.t
        ; continue : bool
        }
  [@@deriving sexp_of]
end

let step (t : t) ~error_log:_ =
  let environment = t.environment in
  let assembly_instruction =
    match Stack.top t.execution_stack.macro_frames with
    | None -> t.code.statements.(t.execution_stack.code_pointer).assembly_instruction
    | Some { macro_name = _; bindings = _; assembly_instructions; macro_code_pointer } ->
      assembly_instructions.(macro_code_pointer)
  in
  let%bind arguments =
    let bindings =
      match Stack.top t.execution_stack.macro_frames with
      | None -> []
      | Some macro_call -> macro_call.bindings
    in
    List.map assembly_instruction.arguments ~f:(fun argument ->
      Visa_assembler.lookup_argument ~environment ~bindings ~argument
      |> Visa_assembler.Or_located_error.or_error)
    |> Or_error.combine_errors
  in
  match assembly_instruction.operation_kind with
  | Instruction { instruction_name } ->
    let%bind instruction =
      Visa_assembler.build_instruction
        ~environment
        ~loc:assembly_instruction.loc
        ~instruction_name
        ~arguments
      |> Visa_assembler.Or_located_error.or_error
    in
    let%bind continue = execute_instruction t ~instruction in
    return (Step_result.Executed { instruction; continue })
  | Macro_call { macro_name } ->
    let%bind { Visa_assembler.Macro_definition.macro_name; parameters; body } =
      match Map.find environment.macros macro_name with
      | Some macro_definition -> return macro_definition
      | None ->
        Or_error.error_s [%sexp "Macro not found", { macro_name : Visa.Macro_name.t }]
    in
    let%bind bindings =
      match List.zip parameters arguments with
      | Ok bindings -> return bindings
      | Unequal_lengths ->
        Or_error.error_s
          [%sexp
            "Invalid number of macro arguments"
            , { macro_name : Visa.Macro_name.t With_loc.t
              ; expected = (List.length parameters : int)
              ; applied_to = (List.length arguments : int)
              }]
    in
    let macro_frame =
      { Execution_stack.Macro_frame.macro_name
      ; bindings
      ; assembly_instructions = Array.of_list body
      ; macro_code_pointer = 0
      }
    in
    Stack.push t.execution_stack.macro_frames macro_frame;
    return (Step_result.Macro_call { macro_name })
;;

let run (t : t) ~error_log =
  let last_output = ref "" in
  let output_device = Memory.output_device t.memory in
  let count_output = ref 0 in
  with_return (fun return ->
    (* Make it possible to interrupt the simulation on SIGINT. *)
    Sys_unix.catch_break true;
    (try
       while true do
         match step t ~error_log with
         | Error e -> return.return (Error e)
         | Ok (Macro_call { macro_name = _ }) -> ()
         | Ok (Executed { instruction; continue }) ->
           (match instruction with
            | Sleep ->
              if t.config.sleep
              then (
                let current_time = Core_unix.gettimeofday () in
                let start_of_current_sec =
                  current_time |> Core_unix.gmtime |> Core_unix.timegm
                in
                Core_thread.delay (1. -. (current_time -. start_of_current_sec)))
            | Write _ ->
              let output = Output_device.to_string output_device in
              if String.( <> ) output !last_output
              then (
                last_output := output;
                print_endline output;
                incr count_output)
            | _ -> ());
           if (not continue)
              ||
              match t.config.stop_after_n_outputs with
              | None -> false
              | Some count -> !count_output >= count
           then return.return (Ok ())
       done
     with
     | Sys_unix.Break -> ());
    Ok ())
;;

let main =
  Command.basic
    ~summary:"parse an assembler program and simulate its execution"
    (let open Command.Let_syntax in
     let%map_open filename = anon ("FILE" %: string)
     and error_log_config = Error_log.Config.param
     and config = Config.param in
     Error_log.report_and_exit ~config:error_log_config (fun error_log ->
       let open Or_error.Let_syntax in
       let program =
         Parsing_utils.parse_file_exn (module Visa_syntax) ~filename ~error_log
       in
       let%bind visa_simulator = create ~config ~error_log ~program in
       run visa_simulator ~error_log))
;;
