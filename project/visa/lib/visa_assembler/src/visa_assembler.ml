module Assembly_construct = struct
  type t =
    | Label_introduction of { label : Visa.Label.t Loc.Txt.t }
    | Assembly_instruction of { assembly_instruction : Visa.Assembly_instruction.t }
end

module Macro_definition = struct
  type t =
    { macro_name : Visa.Macro_name.t Loc.Txt.t
    ; parameters : Visa.Parameter_name.t list
    ; body : Visa.Assembly_instruction.t list
    }
  [@@deriving sexp_of]
end

module Environment = struct
  type t =
    { constants : Visa.Program.Constant_kind.t Loc.Txt.t Map.M(Visa.Constant_name).t
    ; macros : Macro_definition.t Map.M(Visa.Macro_name).t
    ; labels : Visa.Label.t Loc.Txt.t Map.M(Visa.Label).t
    }
  [@@deriving sexp_of]
end

let build_environment ~(program : Visa.Program.t) =
  let constants = Hashtbl.create (module Visa.Constant_name) in
  let macros = Hashtbl.create (module Visa.Macro_name) in
  let labels = Hashtbl.create (module Visa.Label) in
  let code : Assembly_construct.t Queue.t = Queue.create () in
  let pending_label_introduction : Visa.Label.t Loc.Txt.t option ref = ref None in
  let emit_code ~assembly_instruction =
    (match !pending_label_introduction with
     | None -> ()
     | Some label ->
       Queue.enqueue code (Label_introduction { label });
       pending_label_introduction := None);
    Queue.enqueue code (Assembly_instruction { assembly_instruction })
  in
  List.iter program ~f:(fun top_level_construct ->
    match top_level_construct with
    | Newline | Comment { text = (_ : string) } -> ()
    | Constant_definition { constant_name; constant_kind } ->
      if Hashtbl.mem constants constant_name.txt
      then
        Err.error
          ~loc:constant_name.loc
          [ Pp.text "Multiple definition of constants is not allowed"
          ; Pp.text
              (Sexp.to_string_hum
                 [%sexp { constant_name : Visa.Constant_name.t Loc.Txt.t }])
          ];
      Hashtbl.set
        constants
        ~key:constant_name.txt
        ~data:(Loc.Txt.map constant_name ~f:(Fn.const constant_kind))
    | Macro_definition { macro_name; parameters; body } ->
      if Hashtbl.mem macros macro_name.txt
      then
        Err.error
          ~loc:macro_name.loc
          [ Pp.text "Multiple definition of macros is not allowed"
          ; Pp.text
              (Sexp.to_string_hum [%sexp { macro_name : Visa.Macro_name.t Loc.Txt.t }])
          ];
      Hashtbl.set
        macros
        ~key:macro_name.txt
        ~data:{ Macro_definition.macro_name; parameters; body }
    | Label_introduction { label } ->
      (match !pending_label_introduction with
       | None -> ()
       | Some label ->
         Err.error
           ~loc:label.loc
           [ Pp.textf
               "Label '%s' was not followed by any instruction"
               (Visa.Label.to_string label.txt)
           ]);
      pending_label_introduction := Some label;
      if Hashtbl.mem labels label.txt
      then
        Err.error
          ~loc:label.loc
          [ Pp.text "Multiple definition of label is not allowed"
          ; Pp.text (Sexp.to_string_hum [%sexp { label : Visa.Label.t Loc.Txt.t }])
          ];
      Hashtbl.set labels ~key:label.txt ~data:label
    | Assembly_instruction { assembly_instruction } -> emit_code ~assembly_instruction);
  let code = Queue.to_list code in
  let environment =
    { Environment.constants =
        constants |> Hashtbl.to_alist |> Map.of_alist_exn (module Visa.Constant_name)
    ; macros = macros |> Hashtbl.to_alist |> Map.of_alist_exn (module Visa.Macro_name)
    ; labels = labels |> Hashtbl.to_alist |> Map.of_alist_exn (module Visa.Label)
    }
  in
  environment, code
;;

let check_unused_macro_parameters ~(environment : Environment.t) =
  Map.iter environment.macros ~f:(fun { macro_name; parameters; body } ->
    let used_parameters = Hash_set.create (module Visa.Parameter_name) in
    List.iter body ~f:(function { loc = _; operation_kind = _; arguments } ->
        List.iter arguments ~f:(fun argument ->
          match argument.txt with
          | Parameter { parameter_name } -> Hash_set.add used_parameters parameter_name
          | _ -> ()));
    let unused_parameters =
      List.filter parameters ~f:(fun parameter_name ->
        not (Hash_set.mem used_parameters parameter_name))
    in
    if not (List.is_empty unused_parameters)
    then
      Err.warning
        ~loc:macro_name.loc
        [ Pp.text "Unused macro parameters"
        ; Pp.text
            (Sexp.to_string_hum
               [%sexp
                 { macro_name : Visa.Macro_name.t Loc.Txt.t
                 ; unused_parameters : Visa.Parameter_name.t list
                 }])
        ])
;;

let check_unused_definitions
      ~(environment : Environment.t)
      ~(assembly_constructs : Assembly_construct.t list)
  =
  let used_constants = Hash_set.create (module Visa.Constant_name) in
  let used_macros = Hash_set.create (module Visa.Macro_name) in
  let used_labels = Hash_set.create (module Visa.Label) in
  List.iter assembly_constructs ~f:(function
    | Label_introduction { label = (_ : Visa.Label.t Loc.Txt.t) } -> ()
    | Assembly_instruction
        { assembly_instruction = { loc = _; operation_kind; arguments } } ->
      let () =
        match operation_kind with
        | Macro_call { macro_name } -> Hash_set.add used_macros macro_name
        | Instruction { instruction_name = _ } -> ()
      in
      List.iter arguments ~f:(fun argument ->
        match argument.txt with
        | Value { value = (_ : int) }
        | Address { address = (_ : Visa.Address.t) }
        | Register { register_name = (_ : Visa.Register_name.t) }
        | Parameter { parameter_name = (_ : Visa.Parameter_name.t) } -> ()
        | Constant { constant_name } -> Hash_set.add used_constants constant_name
        | Label { label } -> Hash_set.add used_labels label));
  Map.iteri environment.constants ~f:(fun ~key:constant_name ~data:constant ->
    if not (Hash_set.mem used_constants constant_name)
    then
      Err.warning
        ~loc:constant.loc
        [ Pp.textf "Unused constant '%s'" (Visa.Constant_name.to_string constant_name) ]);
  Map.iter environment.macros ~f:(fun { macro_name; _ } ->
    if not (Hash_set.mem used_macros macro_name.txt)
    then
      Err.warning
        ~loc:macro_name.loc
        [ Pp.textf "Unused macro '%s'" (Visa.Macro_name.to_string macro_name.txt) ]);
  Map.iter environment.labels ~f:(fun label ->
    if not (Hash_set.mem used_labels label.txt)
    then
      Err.warning
        ~loc:label.loc
        [ Pp.textf "Unused label '%s'" (Visa.Label.to_string label.txt) ]);
  ()
;;

module Or_located_error = struct
  type 'a t = ('a, Loc.t * Error.t) Result.t

  let or_error = function
    | Ok _ as ok -> ok
    | Error (_loc, e) -> Error e
  ;;
end

let build_instruction ~(environment : Environment.t) ~loc ~instruction_name ~arguments
  : Visa.Label.t Visa.Instruction.t Or_located_error.t
  =
  let open Result.Let_syntax in
  let arity_error ~expects =
    Error
      ( loc
      , Error.create_s
          [%sexp
            "Invalid number of arguments"
          , { instruction_name : Visa.Instruction_name.t
            ; expects : int
            ; is_applied_to = (List.length arguments : int)
            }] )
  in
  let zero_argument () =
    match arguments with
    | [] -> return ()
    | _ :: _ -> arity_error ~expects:0
  in
  let one_argument () =
    match arguments with
    | [ x ] -> return x
    | [] | _ :: _ :: _ -> arity_error ~expects:1
  in
  let two_arguments () =
    match arguments with
    | [ x; y ] -> return (x, y)
    | [] | [ _ ] | _ :: _ :: _ :: _ -> arity_error ~expects:2
  in
  let invalid_argument ~arg ~argument:{ Loc.Txt.txt = argument; loc } ~expected =
    Error
      ( loc
      , Error.create_s
          [%sexp
            "Invalid argument"
          , { instruction_name : Visa.Instruction_name.t
            ; arg : int
            ; expected : Sexp.t
            ; applied_to = (argument : Visa.Assembly_instruction.Argument.t)
            }] )
  in
  let register_name ~arg (argument : Visa.Assembly_instruction.Argument.t Loc.Txt.t) =
    match argument.txt with
    | Register { register_name } -> return register_name
    | _ -> invalid_argument ~arg ~argument ~expected:[%sexp Register]
  in
  let label ~arg (argument : Visa.Assembly_instruction.Argument.t Loc.Txt.t) =
    match argument.txt with
    | Label { label } ->
      if Map.mem environment.labels label
      then return label
      else
        Error
          ( argument.loc
          , Error.create_s [%sexp "Undefined label", { label : Visa.Label.t }] )
    | _ -> invalid_argument ~arg ~argument ~expected:[%sexp Label]
  in
  let address ~arg (argument : Visa.Assembly_instruction.Argument.t Loc.Txt.t) =
    match argument.txt with
    | Address { address } -> return address
    | _ -> invalid_argument ~arg ~argument ~expected:[%sexp Address]
  in
  let value ~arg (argument : Visa.Assembly_instruction.Argument.t Loc.Txt.t) =
    match argument.txt with
    | Value { value } -> return value
    | _ -> invalid_argument ~arg ~argument ~expected:[%sexp Constant]
  in
  match (instruction_name : Visa.Instruction_name.t) with
  | NOP ->
    let%map () = zero_argument () in
    Visa.Instruction.Nop
  | ADD ->
    let%map () = zero_argument () in
    Visa.Instruction.Add
  | AND ->
    let%map () = zero_argument () in
    Visa.Instruction.And
  | SWC ->
    let%map () = zero_argument () in
    Visa.Instruction.Swc
  | CMP ->
    let%map () = zero_argument () in
    Visa.Instruction.Cmp
  | NOT ->
    let%bind arg = one_argument () in
    let%map register_name = register_name ~arg:1 arg in
    Visa.Instruction.Not { register_name }
  | GOF ->
    let%map () = zero_argument () in
    Visa.Instruction.Gof
  | JMP ->
    let%bind arg = one_argument () in
    let%map label = label ~arg:1 arg in
    Visa.Instruction.Jmp { label }
  | JMN ->
    let%bind arg = one_argument () in
    let%map label = label ~arg:1 arg in
    Visa.Instruction.Jmn { label }
  | JMZ ->
    let%bind arg = one_argument () in
    let%map label = label ~arg:1 arg in
    Visa.Instruction.Jmz { label }
  | STORE ->
    let%bind arg1, arg2 = two_arguments () in
    let%map register_name = register_name ~arg:1 arg1
    and address = address ~arg:2 arg2 in
    Visa.Instruction.Store { register_name; address }
  | WRITE ->
    let%bind arg1, arg2 = two_arguments () in
    let%map register_name = register_name ~arg:1 arg1
    and address = address ~arg:2 arg2 in
    Visa.Instruction.Write { register_name; address }
  | LOAD ->
    let%bind arg1, arg2 = two_arguments () in
    let%bind register_name = register_name ~arg:2 arg2 in
    (match arg1.txt with
     | Value _ ->
       let%map value = value ~arg:1 arg1 in
       Visa.Instruction.Load_value { value; register_name }
     | _ ->
       let%map address = address ~arg:1 arg1 in
       Visa.Instruction.Load_address { address; register_name })
  | SLEEP ->
    let%map () = zero_argument () in
    Visa.Instruction.Sleep
;;

let rec lookup_argument
          ~(environment : Environment.t)
          ~bindings
          ~(argument : Visa.Assembly_instruction.Argument.t Loc.Txt.t)
  =
  let open Result.Let_syntax in
  match argument.txt with
  | Parameter { parameter_name } ->
    (match List.Assoc.find bindings parameter_name ~equal:Visa.Parameter_name.equal with
     | Some argument -> lookup_argument ~environment ~bindings ~argument
     | None ->
       Error
         ( argument.loc
         , Error.create_s
             [%sexp "Unbound parameter", { parameter_name : Visa.Parameter_name.t }] ))
  | Constant { constant_name } ->
    (match Map.find environment.constants constant_name with
     | Some constant ->
       return
         { Loc.Txt.txt =
             (match constant.txt with
              | Value { value } -> Visa.Assembly_instruction.Argument.Value { value }
              | Address { address } ->
                Visa.Assembly_instruction.Argument.Address { address })
         ; loc = argument.loc
         }
     | None ->
       Error
         ( argument.loc
         , Error.create_s
             [%sexp "Unbound constant", { constant_name : Visa.Constant_name.t }] ))
  | Value _ | Address _ | Label _ | Register _ -> return argument
;;

let program_to_executable_with_labels ~(program : Visa.Program.t) =
  let environment, assembly_constructs = build_environment ~program in
  check_unused_definitions ~environment ~assembly_constructs;
  check_unused_macro_parameters ~environment;
  let executable : Visa.Executable.With_labels.Line.t Queue.t = Queue.create () in
  let pending_label_introduction : Visa.Label.t Loc.Txt.t option ref = ref None in
  let emit_instruction ~instruction =
    let label_introduction =
      pending_label_introduction.contents |> Option.map ~f:Loc.Txt.txt
    in
    pending_label_introduction := None;
    Queue.enqueue executable { label_introduction; instruction }
  in
  let rec process_assembly_instruction
            ~bindings
            ~assembly_instruction:
              { Visa.Assembly_instruction.loc; operation_kind; arguments }
    =
    match
      List.map arguments ~f:(fun argument ->
        lookup_argument ~environment ~bindings ~argument)
      |> Result.combine_errors
    with
    | Error errors ->
      List.iter errors ~f:(fun (loc, e) ->
        Err.error ~loc [ Pp.text (Error.to_string_hum e) ])
    | Ok arguments ->
      (match operation_kind with
       | Instruction { instruction_name } ->
         (match build_instruction ~environment ~loc ~instruction_name ~arguments with
          | Ok instruction -> emit_instruction ~instruction
          | Error (loc, e) -> Err.error ~loc [ Pp.text (Error.to_string_hum e) ])
       | Macro_call { macro_name } ->
         (match Map.find environment.macros macro_name with
          | None ->
            let macro_name = Visa.Macro_name.to_string macro_name in
            let candidates =
              Map.keys environment.macros |> List.map ~f:Visa.Macro_name.to_string
            in
            Err.error
              ~loc
              [ Pp.textf "Undefined macro '%s'" macro_name ]
              ~hints:(Err.did_you_mean macro_name ~candidates)
          | Some { macro_name; parameters; body } ->
            (match List.zip parameters arguments with
             | Ok bindings ->
               List.iter body ~f:(fun assembly_instruction ->
                 process_assembly_instruction ~bindings ~assembly_instruction)
             | Unequal_lengths ->
               Err.error
                 ~loc
                 [ Pp.text "Invalid number of macro arguments"
                 ; Pp.text
                     (Sexp.to_string_hum
                        [%sexp
                          { macro_name : Visa.Macro_name.t Loc.Txt.t
                          ; expected = (List.length parameters : int)
                          ; applied_to = (List.length arguments : int)
                          }])
                 ])))
  in
  List.iter assembly_constructs ~f:(function
    | Label_introduction { label } -> pending_label_introduction := Some label
    | Assembly_instruction { assembly_instruction } ->
      process_assembly_instruction ~bindings:[] ~assembly_instruction);
  let () = if Err.had_errors () then Err.exit Err.Exit_code.some_error in
  Queue.to_array executable
;;

let program_to_executable ~program =
  program_to_executable_with_labels ~program |> Visa.Executable.resolve_labels
;;
