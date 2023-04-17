open! Core

type env =
  { standard_blocks : Bopkit.Netlist.block Hashtbl.M(String).t
  ; parametrized_blocks : Bopkit.Netlist.block Hashtbl.M(String).t
  }

let empty_env () =
  { standard_blocks = Hashtbl.create (module String)
  ; parametrized_blocks = Hashtbl.create (module String)
  }
;;

(* The semantic currently that was established, is that the latest
   block with a given name overrides any previous one existing.
   Perhaps we can consider emitting a warning in some cases. TBD. *)
let disable_duplicated_block_check = true

let make_env blocks ~error_log =
  let env = empty_env () in
  List.iter blocks ~f:(fun (block : Bopkit.Netlist.block) ->
    match block.name with
    | Standard { name } ->
      (match
         if disable_duplicated_block_check
         then None
         else Hashtbl.find env.standard_blocks name
       with
       | Some previous_block ->
         Error_log.raise
           error_log
           ~loc:block.loc
           [ Pp.textf "Duplicated block name '%s'." name
           ; Pp.textf
               "Previously defined at %S."
               (Loc.to_file_colon_line previous_block.loc)
           ]
       | None -> Hashtbl.set env.standard_blocks ~key:name ~data:block)
    | Parametrized { name; parameters = _; functional_parameters = _ } ->
      (match
         if disable_duplicated_block_check
         then None
         else Hashtbl.find env.parametrized_blocks name
       with
       | Some previous_block ->
         Error_log.raise
           error_log
           ~loc:block.loc
           [ Pp.textf "Duplicated parametrized block name '%s[]'." name
           ; Pp.textf
               "Previously defined at %S."
               (Loc.to_file_colon_line previous_block.loc)
           ]
       | None -> Hashtbl.set env.parametrized_blocks ~key:name ~data:block));
  env
;;

module Specialisation_request = struct
  type t =
    { loc : Loc.t (* Where the request is made *)
    ; parameters : Bopkit.Parameters.t
    ; name : string
    ; arguments : int list
    ; functional_arguments : string list
    }
end

module Specialisation_key = struct
  type t = string

  let of_specialisation_request (sr : Specialisation_request.t) =
    let suff =
      List.fold_left sr.arguments ~init:"" ~f:(fun accu s ->
        accu ^ "[" ^ string_of_int s ^ "]")
    in
    let args =
      List.fold_left sr.functional_arguments ~init:"" ~f:(fun accu s -> accu ^ "_" ^ s)
    in
    Printf.sprintf "%s%s%s" sr.name suff args
  ;;
end

module Expanded_interface = struct
  type t =
    { name : Specialisation_key.t
    ; inputs : Bopkit.Expanded_netlist.variables
    ; outputs : Bopkit.Expanded_netlist.variables
    }
end

module Task = struct
  type t =
    | Specialise of
        { expanded_interface : Expanded_interface.t
        ; parameters : Bopkit.Parameters.t
        ; functional_parameters : (string * string) list
        ; name : string
        }
    | Expand of
        { expanded_interface : Expanded_interface.t
        ; block : Bopkit.Netlist.block
        }
end

(** To avoid functions to be mutually recursive, and to clarify the
     break down of the rest of the file, we use a state that model
     amounts of work that needs to be performed, as well as work that
     has. As work is performed, that state is modified. When there is
     no more work to do, the result can be extracted from the state. *)
type t =
  { env : env
  ; error_log : Error_log.t
  ; primitives : Primitive.env
  ; parameters : Bopkit.Parameters.t
  ; resulting_blocks : Bopkit.Expanded_netlist.block Queue.t
  ; inline_external_blocks : Bopkit.Expanded_netlist.external_block Queue.t
  ; expanded_interfaces : Expanded_interface.t Hashtbl.M(String).t
  ; fresh_internal_counter : int ref
  ; todo : Task.t Queue.t
  }

let fresh_internal (t : t) =
  incr t.fresh_internal_counter;
  t.fresh_internal_counter.contents
;;

let new_inline_external_block (t : t) ~loc ~command =
  let name =
    Loc.to_file_colon_line loc ^ sprintf "[%d]" (Queue.length t.inline_external_blocks)
  in
  Queue.enqueue
    t.inline_external_blocks
    { loc; name; attributes = []; init_messages = []; methods = []; command };
  name
;;

let nested_external_inferred_output_size_error (t : t) ~loc =
  Error_log.raise
    t.error_log
    ~loc
    [ Pp.text "Bopkit won't infer the output size of a nested external call." ]
    ~hints:
      [ Pp.concat
          ~sep:Pp.newline
          [ Pp.text
              "You can either place this call at top level, or add the output size \
               explicitly using the appropriate syntax:"
          ; Pp.text "External command =>        external[N](...)"
          ; Pp.text "External block   =>   $block.method[N](...)"
          ]
      ]
;;

let unknown_block_name (t : t) ~name ~loc ~candidates =
  Error_log.raise
    t.error_log
    ~loc
    [ Pp.textf "Unknown block name '%s'." name ]
    ~hints:(Error_log.did_you_mean name ~candidates)
;;

let variables_of_original_grouping original_grouping =
  let expanded =
    List.concat_map original_grouping ~f:Bopkit.Expand_utils.expand_const_variable
  in
  { Bopkit.Expanded_netlist.expanded; original_grouping }
;;

let expand_variables (t : t) ~variables ~parameters =
  List.map variables ~f:(fun variable ->
    Bopkit.Expand_utils.eval_variable variable ~error_log:t.error_log ~parameters)
  |> variables_of_original_grouping
;;

let request_expansion (t : t) ~name ~loc =
  match Hashtbl.find t.expanded_interfaces name with
  | Some s -> s
  | None ->
    (* This is a new request that we have to enqueue. *)
    let block =
      match Hashtbl.find t.env.standard_blocks name with
      | Some block -> block
      | None ->
        unknown_block_name
          t
          ~name
          ~loc
          ~candidates:(Hashtbl.keys t.env.standard_blocks @ Map.keys t.primitives)
    in
    let inputs = expand_variables t ~variables:block.inputs ~parameters:t.parameters in
    let outputs = expand_variables t ~variables:block.outputs ~parameters:t.parameters in
    let expanded_interface = { Expanded_interface.name; inputs; outputs } in
    Hashtbl.set t.expanded_interfaces ~key:name ~data:expanded_interface;
    Queue.enqueue t.todo (Expand { expanded_interface; block });
    expanded_interface
;;

let request_specialisation
  (t : t)
  ({ Specialisation_request.loc; parameters; name; arguments; functional_arguments } as
  specialisation_request)
  =
  let specialisation_key =
    Specialisation_key.of_specialisation_request specialisation_request
  in
  match Hashtbl.find t.expanded_interfaces specialisation_key with
  | Some s -> s
  | None ->
    (* This is a new request that we have to enqueue. *)
    let block =
      match Hashtbl.find t.env.parametrized_blocks name with
      | Some block -> block
      | None ->
        unknown_block_name
          t
          ~name
          ~loc
          ~candidates:(Hashtbl.keys t.env.parametrized_blocks)
    in
    let block_parameters, block_functional_parameters =
      match block.name with
      | Standard _ -> assert false
      | Parametrized { name = _; parameters = p; functional_parameters = f } ->
        let loc = block.loc in
        let duplicated_parameters =
          List.find_all_dups p ~compare:String.compare
          |> List.sort ~compare:String.compare
        in
        let duplicated_functional_parameters =
          List.find_all_dups f ~compare:String.compare
          |> List.sort ~compare:String.compare
        in
        if not (List.is_empty duplicated_parameters)
        then
          Error_log.raise
            t.error_log
            ~loc
            [ Pp.textf
                "Duplication of block parameter(s) '%s'."
                (String.concat ~sep:", " duplicated_parameters)
            ];
        if not (List.is_empty duplicated_functional_parameters)
        then
          Error_log.raise
            t.error_log
            ~loc
            [ Pp.textf
                "Duplication of block functional parameter(s): '%s'."
                (String.concat ~sep:", " duplicated_functional_parameters)
            ];
        p, f
    in
    let new_parameters =
      let expected = List.length block_parameters in
      let applied_to = List.length arguments in
      if expected <> applied_to
      then
        Error_log.raise
          t.error_log
          ~loc
          [ Pp.textf
              "Block '%s[_]' expects %d parameters but is applied to %d"
              name
              expected
              applied_to
          ]
      else
        List.zip_exn block_parameters arguments
        |> List.map ~f:(fun (name, v) -> { Bopkit.Parameter.name; value = Int v })
    in
    let functional_parameters =
      let expected = List.length block_functional_parameters in
      let applied_to = List.length functional_arguments in
      if expected <> applied_to
      then
        Error_log.raise
          t.error_log
          ~loc
          [ Pp.textf
              "Block '%s<_>' expects %d functional parameters but is applied to %d"
              name
              expected
              applied_to
          ]
      else List.zip_exn block_functional_parameters functional_arguments
    in
    let parameters = new_parameters @ parameters in
    let inputs = expand_variables t ~variables:block.inputs ~parameters in
    let outputs = expand_variables t ~variables:block.outputs ~parameters in
    let expanded_interface =
      { Expanded_interface.name = specialisation_key; inputs; outputs }
    in
    Hashtbl.set t.expanded_interfaces ~key:specialisation_key ~data:expanded_interface;
    Queue.enqueue
      t.todo
      (Specialise { expanded_interface; parameters; functional_parameters; name });
    expanded_interface
;;

let expand_nodes_control_structure (t : t) node ~parameters =
  Bopkit.Control_structure.expand
    node
    ~error_log:t.error_log
    ~parameters
    ~f:(fun ~parameters node -> parameters, node)
;;

module Or_unknown = struct
  type 'a t =
    | Known of 'a
    | Unknown
end

let eval_string_with_vars (t : t) str ~loc ~parameters =
  let ok_eval_exn res = Bopkit.Or_eval_error.ok_exn res ~error_log:t.error_log ~loc in
  Bopkit.String_with_vars.eval
    (Bopkit.String_with_vars.parse str |> ok_eval_exn)
    ~parameters
  |> ok_eval_exn
;;

let add_functional_parameters ~functional_parameters ~parameters =
  List.map functional_parameters ~f:(fun (name, v) ->
    { Bopkit.Parameter.name; value = String v })
  @ parameters
;;

let eval_functional_argument
  (t : t)
  (arg : Bopkit.Netlist.functional_argument)
  ~loc
  ~parameters
  ~functional_parameters
  =
  if arg.name_is_quoted
  then
    eval_string_with_vars
      t
      arg.name
      ~loc
      ~parameters:(add_functional_parameters ~functional_parameters ~parameters)
  else (
    match List.Assoc.find functional_parameters arg.name ~equal:String.equal with
    | Some st -> st
    | None ->
      (* Dans ce cas, on laisse tel quel *)
      arg.name)
;;

type expanded_call =
  { call : Bopkit.Expanded_netlist.call
  ; input_width : int Or_unknown.t
  ; output_width : int
  }

let expand_call
  (t : t)
  (call : Bopkit.Netlist.call)
  ~loc
  ~parameters
  ~functional_parameters
  ~expected_output_width
  : expanded_call
  =
  let ok_eval_exn res = Bopkit.Or_eval_error.ok_exn res ~error_log:t.error_log ~loc in
  match call with
  | Block { name; arguments; functional_arguments } ->
    let name =
      match List.Assoc.find functional_parameters name ~equal:String.equal with
      | Some name -> name
      | None -> name
    in
    if List.is_empty arguments && List.is_empty functional_arguments
    then (
      match Map.find t.primitives name with
      | Some { gate_kind = _; input_width; output_width } ->
        { call = Block { name }; input_width = Known input_width; output_width }
      | None ->
        let { Expanded_interface.name; inputs; outputs } =
          request_expansion t ~name ~loc
        in
        { call = Block { name }
        ; input_width = Known (List.length inputs.expanded)
        ; output_width = List.length outputs.expanded
        })
    else (
      let specialisation_request =
        let arguments =
          List.map arguments ~f:(fun argument ->
            Bopkit.Arithmetic_expression.eval argument ~parameters |> ok_eval_exn)
        in
        let functional_arguments =
          List.map functional_arguments ~f:(fun arg ->
            eval_functional_argument t arg ~loc ~parameters ~functional_parameters)
        in
        { Specialisation_request.loc; parameters; name; arguments; functional_arguments }
      in
      let { Expanded_interface.name; inputs; outputs } =
        request_specialisation t specialisation_request
      in
      { call = Block { name }
      ; input_width = Known (List.length inputs.expanded)
      ; output_width = List.length outputs.expanded
      })
  | External_block
      { name; method_name; method_name_is_quoted = _; external_arguments; output_size } ->
    let method_name =
      Option.map method_name ~f:(fun method_name ->
        eval_string_with_vars t method_name ~loc ~parameters)
    in
    let external_arguments =
      List.map external_arguments ~f:(fun arg ->
        eval_string_with_vars t arg ~loc ~parameters)
    in
    let output_width =
      match (expected_output_width : int Or_unknown.t) with
      | Known i -> i
      | Unknown ->
        (match output_size with
         | Specified exp ->
           Bopkit.Arithmetic_expression.eval exp ~parameters |> ok_eval_exn
         | Inferred -> nested_external_inferred_output_size_error t ~loc)
    in
    { call = External_block { name; method_name; external_arguments }
    ; input_width = Unknown
    ; output_width
    }
  | External_command { command; output_size } ->
    let command = eval_string_with_vars t command ~loc ~parameters in
    let name = new_inline_external_block t ~loc ~command in
    let output_width =
      match (expected_output_width : int Or_unknown.t) with
      | Known i -> i
      | Unknown ->
        (match output_size with
         | Specified exp ->
           Bopkit.Arithmetic_expression.eval exp ~parameters |> ok_eval_exn
         | Inferred -> nested_external_inferred_output_size_error t ~loc)
    in
    { call = External_block { name; method_name = None; external_arguments = [] }
    ; input_width = Unknown
    ; output_width
    }
;;

let empty_variables = { Bopkit.Expanded_netlist.expanded = []; original_grouping = [] }

let append_variables
  { Bopkit.Expanded_netlist.expanded = a; original_grouping = b }
  { Bopkit.Expanded_netlist.expanded = c; original_grouping = d }
  : Bopkit.Expanded_netlist.variables
  =
  { expanded = a @ c; original_grouping = b @ d }
;;

let concat_variables all = List.fold_left all ~init:empty_variables ~f:append_variables

let expand_node_nesting
  (t : t)
  (node : Bopkit.Netlist.node)
  ~parameters
  ~functional_parameters
  =
  let { Bopkit.Netlist.loc; comments = _; call; inputs; outputs } = node in
  let outputs = expand_variables t ~variables:outputs ~parameters in
  let { call; _ } =
    expand_call
      t
      call
      ~loc
      ~parameters
      ~functional_parameters
      ~expected_output_width:(Known (List.length outputs.expanded))
  in
  let nodes = Queue.create () in
  let rec aux_list li = List.map li ~f:aux_one |> concat_variables
  and aux_one nested_inputs =
    match (nested_inputs : Bopkit.Netlist.nested_inputs) with
    | Variables { loc = _; comments = _; variables } ->
      expand_variables t ~variables ~parameters
    | Nested_node { loc; comments = _; call; inputs } ->
      let inputs = aux_list inputs in
      let { call; input_width = _; output_width } =
        expand_call
          t
          call
          ~loc
          ~parameters
          ~functional_parameters
          ~expected_output_width:Unknown
      in
      let outputs =
        List.init output_width ~f:(fun _ ->
          Bopkit.Expanded_netlist.Internal (fresh_internal t))
        |> variables_of_original_grouping
      in
      Queue.enqueue nodes { Bopkit.Expanded_netlist.loc; call; inputs; outputs };
      outputs
  in
  Queue.enqueue
    nodes
    { Bopkit.Expanded_netlist.loc; call; inputs = aux_list inputs; outputs };
  Queue.to_list nodes
;;

let create_state blocks ~error_log ~primitives ~parameters =
  let env = make_env blocks ~error_log in
  { env
  ; error_log
  ; primitives
  ; parameters
  ; resulting_blocks = Queue.create ()
  ; inline_external_blocks = Queue.create ()
  ; expanded_interfaces = Hashtbl.create (module String)
  ; fresh_internal_counter = ref (-1)
  ; todo = Queue.create ()
  }
;;

let expand_block
  (t : t)
  ~parameters
  ~functional_parameters
  ~expanded_interface:{ Expanded_interface.name; inputs; outputs }
  ~block:
    { Bopkit.Netlist.loc
    ; head_comments = _
    ; tail_comments = _
    ; name = _
    ; attributes
    ; inputs = _
    ; outputs = _
    ; unused_variables
    ; nodes
    }
  =
  let unused_variables = expand_variables t ~variables:unused_variables ~parameters in
  let nodes =
    List.concat_map nodes ~f:(fun node ->
      let nodes = expand_nodes_control_structure t node ~parameters in
      List.concat_map nodes ~f:(fun (parameters, node) ->
        expand_node_nesting t node ~parameters ~functional_parameters))
  in
  let expanded_block =
    { Bopkit.Expanded_netlist.loc
    ; name
    ; attributes
    ; inputs
    ; outputs
    ; unused_variables
    ; nodes
    }
  in
  Queue.enqueue t.resulting_blocks expanded_block
;;

let work_until_finished (t : t) =
  (* The goal of this function is to empty [to_specialise] and
     [to_expand] by calling the other functions of this module. *)
  while not (Queue.is_empty t.todo) do
    match Queue.dequeue_exn t.todo with
    | Specialise { expanded_interface; parameters; functional_parameters; name } ->
      let block = Hashtbl.find_exn t.env.parametrized_blocks name in
      expand_block t ~parameters ~functional_parameters ~expanded_interface ~block
    | Expand { expanded_interface; block } ->
      expand_block
        t
        ~parameters:t.parameters
        ~functional_parameters:[]
        ~expanded_interface
        ~block
  done
;;

type output =
  { inline_external_blocks : Bopkit.Expanded_netlist.external_block list
  ; blocks : Bopkit.Expanded_netlist.block list
  }

let pass blocks ~error_log ~primitives ~parameters ~main_block_name:_ =
  let blocks = Block_sort.sort blocks ~error_log in
  let t = create_state blocks ~error_log ~primitives ~parameters in
  List.iter blocks ~f:(fun block ->
    (* We expand all blocks, so as to produce all warnings for all blocks. *)
    match block.name with
    | Parametrized _ -> ()
    | Standard { name } ->
      Error_log.debug error_log [ Pp.textf "requesting expansion of %s." name ];
      ignore (request_expansion t ~name ~loc:Loc.dummy_pos : Expanded_interface.t));
  work_until_finished t;
  let blocks = Queue.to_list t.resulting_blocks in
  let blocks = Expanded_block_sort.sort blocks ~error_log:t.error_log in
  { inline_external_blocks = Queue.to_list t.inline_external_blocks; blocks }
;;
