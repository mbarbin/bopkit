open Or_error.Let_syntax

type t = Visa_simulator.t

let next_instruction (t : t) =
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
  return { assembly_instruction with arguments }
;;

let run_bogue (t : t) ~error_log =
  let memory_widget =
    Sexp.to_string_hum [%sexp (t.memory : Visa_simulator.Memory.t)]
    |> Bogue.Widget.text_display ~w:500 ~h:12000
  in
  let memory =
    memory_widget
    |> Bogue.Layout.resident
    |> List.return
    |> Bogue.Layout.tower
    |> Bogue.Layout.make_clip ~h:200
  in
  let code_length = Array.length t.code.statements in
  let code =
    Code.render_lines_for_debugging t.code
    |> String.concat ~sep:"\n"
    |> Bogue.Widget.text_display ~w:500 ~h:12000
    |> Bogue.Layout.resident
    |> List.return
    |> Bogue.Layout.tower
    |> Bogue.Layout.make_clip ~h:400
  in
  let environment =
    Sexp.to_string_hum [%sexp (t.environment : Visa_assembler.Environment.t)]
    |> Bogue.Widget.text_display ~w:500 ~h:1200
    |> Bogue.Layout.resident
    |> List.return
    |> Bogue.Layout.tower
    |> Bogue.Layout.make_clip ~h:200
  in
  let execution_stack_contents () =
    [ [ sprintf
          "code_pointer = %0*d"
          (code_length |> Int.to_string |> String.length)
          t.execution_stack.code_pointer
      ; sprintf
          "Next instruction: %s"
          (match next_instruction t with
           | Ok assembly_instruction ->
             Visa.Assembly_instruction.to_string assembly_instruction
           | Error e -> Error.to_string_hum e)
      ; ""
      ]
    ; Execution_stack.render_lines_for_debugging t.execution_stack
    ]
    |> List.concat
    |> String.concat ~sep:"\n"
  in
  let execution_stack_widget =
    execution_stack_contents () |> Bogue.Widget.text_display ~w:500 ~h:1200
  in
  let execution_stack =
    execution_stack_widget
    |> Bogue.Layout.resident
    |> List.return
    |> Bogue.Layout.tower
    |> Bogue.Layout.make_clip ~h:400
  in
  let update_memory _ =
    Bogue.Widget.set_text
      memory_widget
      (Sexp.to_string_hum [%sexp (t.memory : Visa_simulator.Memory.t)])
  in
  let step arg =
    (match Visa_simulator.step t ~error_log with
     | Error e -> prerr_endline (Sexp.to_string_hum [%sexp (e : Error.t)])
     | Ok (Macro_call { macro_name = _ }) -> ()
     | Ok (Executed { instruction = _; continue = _ }) -> ());
    Bogue.Widget.set_text execution_stack_widget (execution_stack_contents ());
    update_memory arg
  in
  let selected_register = ref Visa.Register_name.R0 in
  let register_value =
    Bogue.Widget.text_input
      ~text:(String.make 8 '0')
      ~prompt:"value"
        (*      ~filter:(fun str ->
                String.length str = 8
                && String.for_all str ~f:(fun c -> Char.equal c '0' || Char.equal c '1'))
        *)
      ~max_size:8
      ()
  in
  let set_register memory_layout arg =
    let register_name = !selected_register in
    let value = Bogue.Widget.get_text_input register_value |> Bogue.Text_input.text in
    let is_ok =
      String.length value = 8
      && String.for_all value ~f:(fun c -> Char.equal c '0' || Char.equal c '1')
    in
    match is_ok with
    | false ->
      Bogue.Popup.info
        "Register values must be of size 8 and contains only 0 and 1"
        memory_layout
    | true ->
      let value = Bit_array.of_01_chars_in_string value |> Bit_array.to_int in
      Visa_simulator.Memory.load_value t.memory ~value ~register_name;
      update_memory arg
  in
  let layout =
    Bogue.Layout.flat
      ~name:"Visa Debugger"
      [ Bogue.Layout.tower
          [ Bogue.Widget.label "Memory" |> Bogue.Layout.resident
          ; Bogue.Layout.tower
              [ memory
              ; Bogue.Layout.flat
                  [ Bogue.Widget.label "register" |> Bogue.Layout.resident
                  ; Bogue.Select.create
                      ~action:(function
                        | 0 -> selected_register := R0
                        | _ -> selected_register := R1)
                      [| "R0"; "R1" |]
                      0
                  ; register_value |> Bogue.Layout.resident ~w:70
                  ; Bogue.Widget.button ~action:(set_register memory) "set"
                    |> Bogue.Layout.resident
                  ]
              ]
          ; Bogue.Widget.label "Code" |> Bogue.Layout.resident
          ; code
          ]
      ; Bogue.Layout.tower
          [ Bogue.Widget.label "Environment" |> Bogue.Layout.resident
          ; environment
          ; Bogue.Widget.label "Execution_stack" |> Bogue.Layout.resident
          ; execution_stack
          ; Bogue.Widget.button ~action:step "Step" |> Bogue.Layout.resident
          ]
      ]
  in
  let main = Bogue.Main.of_layout layout in
  Bogue.Main.run main
;;

let bogue_cmd =
  Command.basic
    ~summary:"parse an assembler program and simulate its execution in a bogue window"
    (let open Command.Let_syntax in
     let%map_open path = anon ("FILE" %: Arg_type.create Fpath.v)
     and error_log_config = Error_log.Config.param
     and visa_simulator_config = Visa_simulator.Config.param in
     Error_log.report_and_exit ~config:error_log_config (fun error_log ->
       let open Or_error.Let_syntax in
       let program = Parsing_utils.parse_file_exn (module Visa_syntax) ~path ~error_log in
       let%bind visa_simulator =
         Visa_simulator.create ~config:visa_simulator_config ~error_log ~program
       in
       run_bogue visa_simulator ~error_log;
       return ()))
;;

let main = Command.group ~summary:"visa simulator" [ "bogue", bogue_cmd ]
