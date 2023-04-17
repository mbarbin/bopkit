open! Core
open! Pp.O

type t = Bopkit.Netlist.t

let string_with_vars str =
  match Bopkit.String_with_vars.parse str with
  | Ok t -> sprintf "%S" (Bopkit.String_with_vars.to_string ~syntax:Percent t)
  | Error e ->
    raise_s
      [%sexp
        "Internal error: Invalid string with var"
        , [%here]
        , { str : string }
        , (e : Bopkit.Eval_error.t)]
;;

let pp_comments comments =
  Pp.concat_map (Bopkit.Comments.value comments) ~f:(fun comment ->
    Pp.concat_map (Bopkit.Comment.render comment) ~f:(fun line ->
      Pp.verbatim line ++ Pp.newline))
;;

(* Tail comments are printed without a trailing newline so they can fit in
   indentation boxes without causing an extra line of indentation at the end. *)
let pp_tail_comments comments =
  Pp.concat_map (Bopkit.Comments.value comments) ~f:(fun comment ->
    Pp.concat_map (Bopkit.Comment.render comment) ~f:(fun line ->
      Pp.newline ++ Pp.verbatim line))
;;

let pp_include_file { Bopkit.Netlist.loc = _; comments; include_file_kind } =
  Pp.concat
    [ pp_comments comments
    ; (match include_file_kind with
       | File_path file -> Pp.verbatim (sprintf "#include %s" (string_with_vars file))
       | Distribution { file; file_is_quoted } ->
         Pp.verbatim
           (if file_is_quoted
            then sprintf "#include <%s>" (string_with_vars file)
            else sprintf "#include <%s>" file))
    ]
;;

let pp_parameter { Bopkit.Netlist.loc = _; comments; name; parameter_value } =
  pp_comments comments
  ++ Pp.verbatim (sprintf "#define %s " name)
  ++
  match parameter_value with
  | DefInt e -> Bopkit.Arithmetic_expression.pp e
  | DefString s -> Pp.verbatim (string_with_vars s)
  | DefCondInt (if_, then_, else_) ->
    Pp.concat
      [ Pp.verbatim "( "
      ; Bopkit.Conditional_expression.pp if_
      ; Pp.verbatim " ? "
      ; Bopkit.Arithmetic_expression.pp then_
      ; Pp.verbatim " : "
      ; Bopkit.Arithmetic_expression.pp else_
      ; Pp.verbatim " )"
      ]
  | DefCondString (if_, then_, else_) ->
    Pp.concat
      [ Pp.verbatim "( "
      ; Bopkit.Conditional_expression.pp if_
      ; Pp.verbatim " ? "
      ; Pp.verbatim (string_with_vars then_)
      ; Pp.verbatim " : "
      ; Pp.verbatim (string_with_vars else_)
      ; Pp.verbatim " )"
      ]
;;

let pp_memory
  { Bopkit.Netlist.loc = _
  ; comments
  ; name
  ; memory_kind
  ; address_width
  ; data_width
  ; memory_content
  }
  =
  Pp.concat
    [ pp_comments comments
    ; (match memory_kind with
       | RAM -> Pp.verbatim (sprintf "RAM %s" name)
       | ROM -> Pp.verbatim (sprintf "ROM %s" name))
    ; Pp.verbatim " ("
    ; Bopkit.Arithmetic_expression.pp address_width
    ; Pp.verbatim ", "
    ; Bopkit.Arithmetic_expression.pp data_width
    ; Pp.verbatim ")"
    ; (match memory_content with
       | Zero -> Pp.nop
       | File file -> Pp.verbatim (sprintf " = file(%s)" (string_with_vars file))
       | Text text -> Pp.verbatim (sprintf " = text {%s}" text))
    ]
;;

let pp_attributes attributes =
  Pp.concat
    [ Pp.verbatim "[ "
    ; Pp.concat_map attributes ~sep:(Pp.verbatim ", ") ~f:Pp.verbatim
    ; Pp.verbatim " ]"
    ]
;;

let rec pp_control_structure
  : type a b.
    first_in_group:bool
    -> (first_in_group:bool -> a -> b Pp.t)
    -> a Bopkit.Control_structure.t
    -> b Pp.t
  =
 fun ~first_in_group aux t ->
  match t with
  | Node a -> aux ~first_in_group a
  | For_loop
      { loc = _; head_comments; tail_comments; ident; left_bound; right_bound; nodes } ->
    (if (not first_in_group) && not (Bopkit.Comments.is_empty head_comments)
     then Pp.newline
     else Pp.nop)
    ++ pp_comments head_comments
    ++ (Pp.concat
          [ Pp.verbatim "for "
          ; Pp.verbatim ident
          ; Pp.verbatim " = "
          ; (if Bopkit.Arithmetic_expression.equal left_bound right_bound
             then Bopkit.Arithmetic_expression.pp left_bound
             else
               Bopkit.Arithmetic_expression.pp left_bound
               ++ Pp.verbatim " to "
               ++ Bopkit.Arithmetic_expression.pp right_bound)
          ; Pp.newline
          ; List.mapi nodes ~f:(fun i t -> i, t)
            |> Pp.concat_map ~sep:Pp.newline ~f:(fun (i, t) ->
                 pp_control_structure ~first_in_group:(i = 0) aux t)
          ; pp_tail_comments tail_comments
          ]
        |> Pp.box ~indent:2)
    ++ Pp.newline
    ++ Pp.verbatim "end for;"
  | If_then_else
      { loc = _
      ; head_comments
      ; then_tail_comments
      ; tail_comments
      ; if_condition
      ; then_nodes
      ; else_nodes
      } ->
    (if (not first_in_group) && not (Bopkit.Comments.is_empty head_comments)
     then Pp.newline
     else Pp.nop)
    ++ pp_comments head_comments
    ++ (Pp.concat
          [ Pp.verbatim "if "
          ; Bopkit.Conditional_expression.pp if_condition
          ; Pp.verbatim " then"
          ; Pp.newline
          ; List.mapi then_nodes ~f:(fun i t -> i, t)
            |> Pp.concat_map ~sep:Pp.newline ~f:(fun (i, t) ->
                 pp_control_structure ~first_in_group:(i = 0) aux t)
          ; pp_tail_comments then_tail_comments
          ; (if List.is_empty else_nodes then pp_tail_comments tail_comments else Pp.nop)
          ]
        |> Pp.box ~indent:2)
    ++ (if List.is_empty else_nodes
        then Pp.nop
        else
          Pp.newline
          ++ (Pp.concat
                [ Pp.verbatim "else"
                ; Pp.newline
                ; List.mapi else_nodes ~f:(fun i t -> i, t)
                  |> Pp.concat_map ~sep:Pp.newline ~f:(fun (i, t) ->
                       pp_control_structure ~first_in_group:(i = 0) aux t)
                ; pp_tail_comments tail_comments
                ]
              |> Pp.box ~indent:2))
    ++ Pp.newline
    ++ Pp.verbatim "end if;"
;;

let pp_external_api ~first_in_group a =
  match (a : Bopkit.Netlist.external_block_api_element) with
  | Init_message { loc = _; comments; message } ->
    Pp.concat
      [ (if (not first_in_group) && not (Bopkit.Comments.is_empty comments)
         then Pp.newline
         else Pp.nop)
      ; pp_comments comments
      ; Pp.verbatim "init "
      ; Pp.verbatim (string_with_vars message)
      ]
  | Method
      { loc = _
      ; comments
      ; method_name
      ; method_name_is_quoted
      ; attributes
      ; implementation_name
      } ->
    Pp.concat
      [ (if (not first_in_group) && not (Bopkit.Comments.is_empty comments)
         then Pp.newline
         else Pp.nop)
      ; pp_comments comments
      ; Pp.verbatim "def "
      ; (if List.is_empty attributes
         then Pp.nop
         else pp_attributes attributes ++ Pp.verbatim " ")
      ; Pp.verbatim
          (if method_name_is_quoted then string_with_vars method_name else method_name)
      ; Pp.verbatim " "
      ; Pp.verbatim (string_with_vars implementation_name)
      ]
;;

let pp_external_block
  { Bopkit.Netlist.loc = _; head_comments; tail_comments; name; attributes; api; command }
  =
  pp_comments head_comments
  ++ (Pp.concat
        [ Pp.verbatim "external "
        ; (match attributes with
           | [] -> Pp.nop
           | _ :: _ as list -> pp_attributes list ++ Pp.verbatim " ")
        ; Pp.verbatim name
        ; Pp.verbatim (sprintf " %s" (string_with_vars command))
        ; (match api with
           | [] -> Pp.nop
           | _ :: _ as list ->
             Pp.newline
             ++ (List.mapi list ~f:(fun i t -> i, t)
                 |> Pp.concat_map ~sep:Pp.newline ~f:(fun (i, api) ->
                      pp_control_structure ~first_in_group:(i = 0) pp_external_api api)))
        ; pp_tail_comments tail_comments
        ]
      |> Pp.box ~indent:2)
  ++
  if List.is_empty api && Bopkit.Comments.is_empty tail_comments
  then Pp.nop
  else Pp.newline ++ Pp.verbatim "end external;"
;;

let pp_index aux (t : Bopkit.Netlist.index) =
  match t with
  | Segment a -> Pp.concat [ Pp.verbatim ":["; aux a; Pp.verbatim "]" ]
  | Interval (a, b) ->
    Pp.concat [ Pp.verbatim "["; aux a; Pp.verbatim ".."; aux b; Pp.verbatim "]" ]
  | Index a -> Pp.concat [ Pp.verbatim "["; aux a; Pp.verbatim "]" ]
;;

let pp_variable v =
  match (v : Bopkit.Netlist.variable) with
  | Signal { name } -> Pp.verbatim name
  | Bus { loc = _; name; indexes } ->
    Pp.verbatim name
    ++ Pp.concat_map indexes ~f:(fun index ->
         pp_index Bopkit.Arithmetic_expression.pp index)
;;

let pp_external_call_output_size t =
  match (t : Bopkit.Netlist.external_call_output_size) with
  | Inferred -> Pp.nop
  | Specified e ->
    Pp.concat [ Pp.verbatim "["; Bopkit.Arithmetic_expression.pp e; Pp.verbatim "]" ]
;;

let pp_functional_argument { Bopkit.Netlist.name; name_is_quoted } =
  if name_is_quoted then Pp.verbatim (string_with_vars name) else Pp.verbatim name
;;

let rec pp_call (t : Bopkit.Netlist.call) ~(inputs : Bopkit.Netlist.nested_inputs list) =
  match t with
  | Block { name; arguments; functional_arguments } ->
    let name =
      match force Fmt_command.bopkit_force_fmt with
      | false -> name
      | true ->
        (* CR mbarbin: This allows for a transition during which we auto-correct
           netlist to the new primitive names *)
        let primitives = force Bopkit_circuit.Gate_kind.Primitive.all in
        (match
           List.find primitives ~f:(fun t -> List.mem t.aliases name ~equal:String.equal)
         with
         | None -> name
         | Some t -> List.hd_exn t.aliases)
    in
    let call =
      Pp.concat
        [ Pp.verbatim name
        ; Pp.concat_map arguments ~f:(fun param ->
            Pp.concat
              [ Pp.verbatim "["; Bopkit.Arithmetic_expression.pp param; Pp.verbatim "]" ])
        ; (match functional_arguments with
           | [] -> Pp.nop
           | _ :: _ as list ->
             Pp.concat
               [ Pp.verbatim "<"
               ; Pp.concat_map
                   list
                   ~sep:(Pp.verbatim "," ++ Pp.space)
                   ~f:pp_functional_argument
               ; Pp.verbatim ">"
               ])
        ]
    in
    Pp.concat
      [ call
      ; Pp.verbatim "("
      ; Pp.cut
      ; Pp.concat_map
          inputs
          ~sep:(Pp.verbatim "," ++ Pp.space)
          ~f:(fun input -> pp_imbrication input)
      ; Pp.verbatim ")"
      ]
    |> Pp.hvbox ~indent:2
  | External_block
      { name; method_name; method_name_is_quoted; external_arguments; output_size } ->
    Pp.concat
      [ Pp.verbatim "$"
      ; Pp.verbatim name
      ; (match method_name with
         | None -> Pp.nop
         | Some method_name ->
           Pp.verbatim "."
           ++ Pp.verbatim
                (if method_name_is_quoted
                 then string_with_vars method_name
                 else method_name))
      ; pp_external_call_output_size output_size
      ; Pp.verbatim "("
      ; Pp.cut
      ; Pp.concat_map
          external_arguments
          ~sep:(Pp.verbatim "," ++ Pp.space)
          ~f:(fun arg -> Pp.verbatim (string_with_vars arg))
      ; (if List.is_empty external_arguments || List.is_empty inputs
         then Pp.nop
         else Pp.verbatim "," ++ Pp.space)
      ; Pp.concat_map
          inputs
          ~sep:(Pp.verbatim "," ++ Pp.space)
          ~f:(fun input -> pp_imbrication input)
      ; Pp.verbatim ")"
      ]
    |> Pp.hvbox ~indent:2
  | External_command { command; output_size } ->
    Pp.concat
      [ Pp.verbatim "external" ++ pp_external_call_output_size output_size
      ; Pp.verbatim "("
      ; Pp.verbatim (string_with_vars command)
      ; Pp.concat_map inputs ~f:(fun input ->
          Pp.verbatim "," ++ Pp.space ++ pp_imbrication input)
      ; Pp.verbatim ")"
      ]
    |> Pp.hvbox ~indent:2

and pp_imbrication (t : Bopkit.Netlist.nested_inputs) =
  match t with
  | Nested_node { loc = _; comments; call; inputs } ->
    pp_comments comments ++ pp_call call ~inputs
  | Variables { loc = _; comments; variables } ->
    pp_comments comments
    ++
    (match variables with
     | [] -> Pp.nop
     | [ variable ] -> pp_variable variable
     | _ :: _ :: _ ->
       Pp.concat
         [ Pp.verbatim "("
         ; Pp.cut
         ; Pp.concat_map
             variables
             ~sep:(Pp.verbatim "," ++ Pp.space)
             ~f:(fun var -> pp_variable var)
         ; Pp.verbatim ")"
         ]
       |> Pp.hvbox ~indent:2)
;;

let pp_node
  ~first_in_group
  ({ loc = _; comments; call; inputs; outputs } as t : Bopkit.Netlist.node)
  =
  let outputs =
    Pp.concat_map
      outputs
      ~sep:(Pp.verbatim "," ++ Pp.space)
      ~f:(fun output -> pp_variable output)
  in
  (* Because it is oftentimes the case that external calls do not return
     anything (e.g. graphical components, debugging, etc.) we allow for a
     special syntax of omitting the '=' in case of empty outputs. Currently it
     is not generalized to all blocks. Maybe it should? TBD. *)
  let skip_outputs =
    List.is_empty t.outputs
    &&
    match t.call with
    | External_block _ | External_command _ -> true
    | Block _ -> false
  in
  (if (not first_in_group) && not (Bopkit.Comments.is_empty comments)
   then Pp.newline
   else Pp.nop)
  ++ pp_comments comments
  ++ (Pp.concat
        [ (if skip_outputs then Pp.nop else outputs ++ Pp.verbatim " =" ++ Pp.space)
        ; pp_call call ~inputs
        ; Pp.verbatim ";"
        ]
      |> Pp.box ~indent:2)
;;

let pp_block
  { Bopkit.Netlist.loc = _
  ; head_comments
  ; tail_comments
  ; name
  ; attributes
  ; inputs
  ; outputs
  ; unused_variables
  ; nodes
  }
  =
  let name =
    match name with
    | Standard { name } -> Pp.verbatim name
    | Parametrized { name; parameters; functional_parameters } ->
      Pp.concat
        [ Pp.verbatim name
        ; Pp.concat_map parameters ~f:(fun parameter ->
            Pp.concat [ Pp.verbatim "["; Pp.verbatim parameter; Pp.verbatim "]" ])
        ; (match functional_parameters with
           | [] -> Pp.nop
           | _ :: _ as list ->
             Pp.concat
               [ Pp.verbatim "<"
               ; Pp.concat_map list ~sep:(Pp.verbatim "," ++ Pp.space) ~f:Pp.verbatim
               ; Pp.verbatim ">"
               ])
        ]
  in
  let output_with_parenthesis =
    match outputs with
    | [ _ ] -> false
    | [] | _ :: _ :: _ -> true
  in
  Pp.concat
    [ pp_comments head_comments
    ; (if List.is_empty attributes then Pp.nop else pp_attributes attributes ++ Pp.newline)
    ; Pp.concat
        [ name
        ; Pp.verbatim "("
        ; Pp.concat_map
            inputs
            ~sep:(Pp.verbatim "," ++ Pp.space)
            ~f:(fun input -> pp_variable input)
        ; Pp.verbatim ") = "
        ; (if output_with_parenthesis then Pp.verbatim "(" else Pp.nop)
        ; Pp.concat_map
            outputs
            ~sep:(Pp.verbatim "," ++ Pp.space)
            ~f:(fun input -> pp_variable input)
        ; (if output_with_parenthesis then Pp.verbatim ")" else Pp.nop)
        ]
      |> Pp.box ~indent:2
    ; (if List.is_empty unused_variables
       then Pp.nop
       else (
         let unused_with_parenthesis =
           match unused_variables with
           | [ _ ] -> false
           | _ -> true
         in
         Pp.newline
         ++ (Pp.concat
               [ Pp.verbatim "with unused = "
               ; (if unused_with_parenthesis then Pp.verbatim "(" else Pp.nop)
               ; Pp.concat_map
                   unused_variables
                   ~sep:(Pp.verbatim "," ++ Pp.space)
                   ~f:(fun input -> pp_variable input)
               ; (if unused_with_parenthesis then Pp.verbatim ")" else Pp.nop)
               ]
             |> Pp.box ~indent:2)))
    ; Pp.newline
    ; Pp.concat
        [ Pp.verbatim "where"
        ; List.mapi nodes ~f:(fun i t -> i, t)
          |> Pp.concat_map ~f:(fun (i, node) ->
               Pp.newline ++ pp_control_structure ~first_in_group:(i = 0) pp_node node)
        ; pp_tail_comments tail_comments
        ]
      |> Pp.box ~indent:2
    ; Pp.newline
    ; Pp.verbatim "end where;"
    ]
;;

let pp
  ({ Bopkit.Netlist.include_files
   ; parameters
   ; memories
   ; external_blocks
   ; blocks
   ; eof_comments
   } :
    t)
  =
  let include_files =
    match include_files with
    | [] -> None
    | _ :: _ ->
      List.mapi include_files ~f:(fun i t -> i, t)
      |> Pp.concat_map ~f:(fun (i, include_file) ->
           (if i > 0 && not (Bopkit.Comments.is_empty include_file.comments)
            then Pp.newline
            else Pp.nop)
           ++ pp_include_file include_file
           ++ Pp.newline)
      |> Option.return
  in
  let parameters =
    match parameters with
    | [] -> None
    | _ :: _ ->
      List.mapi parameters ~f:(fun i t -> i, t)
      |> Pp.concat_map ~f:(fun (i, parameter) ->
           (if i > 0 && not (Bopkit.Comments.is_empty parameter.comments)
            then Pp.newline
            else Pp.nop)
           ++ pp_parameter parameter
           ++ Pp.newline)
      |> Option.return
  in
  let memories =
    match memories with
    | [] -> None
    | _ :: _ ->
      List.mapi memories ~f:(fun i t -> i, t)
      |> Pp.concat_map ~f:(fun (i, memory) ->
           (if i > 0 && not (Bopkit.Comments.is_empty memory.comments)
            then Pp.newline
            else Pp.nop)
           ++ pp_memory memory
           ++ Pp.newline)
      |> Option.return
  in
  let external_blocks =
    match external_blocks with
    | [] -> None
    | _ :: _ ->
      Pp.concat_map external_blocks ~sep:Pp.newline ~f:(fun external_block ->
        pp_external_block external_block ++ Pp.newline)
      |> Option.return
  in
  let blocks =
    match blocks with
    | [] -> None
    | _ :: _ ->
      Pp.concat_map blocks ~sep:Pp.newline ~f:(fun block -> pp_block block ++ Pp.newline)
      |> Option.return
  in
  let eof_comments =
    if Bopkit.Comments.is_empty eof_comments
    then None
    else Some (pp_comments eof_comments)
  in
  Pp.concat
    ~sep:Pp.newline
    (List.filter_opt
       [ include_files; parameters; memories; external_blocks; blocks; eof_comments ])
;;
