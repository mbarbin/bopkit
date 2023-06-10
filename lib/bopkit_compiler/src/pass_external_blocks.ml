open! Core

let pass (external_block : Bopkit.Netlist.external_block) ~error_log ~parameters =
  let eval_string ~parameters str =
    let ok_eval_exn res =
      Bopkit.Or_eval_error.ok_exn res ~error_log ~loc:external_block.loc
    in
    Bopkit.String_with_vars.eval
      (Bopkit.String_with_vars.parse str |> ok_eval_exn)
      ~parameters
    |> ok_eval_exn
  in
  let eval_api ~parameters element : Bopkit.Netlist.external_block_api_element =
    match (element : Bopkit.Netlist.external_block_api_element) with
    | Init_message { loc; comments; message } ->
      Init_message { loc; comments; message = eval_string ~parameters message }
    | Method { loc; comments; method_name = a; method_name_is_quoted; attributes = att }
      ->
      Method
        { loc
        ; comments
        ; method_name = (if method_name_is_quoted then eval_string ~parameters a else a)
        ; method_name_is_quoted
        ; attributes = att
        }
  in
  let api =
    List.concat_map external_block.api ~f:(fun element ->
      Bopkit.Control_structure.expand element ~error_log ~parameters ~f:eval_api)
  in
  let init_messages = Queue.create () in
  let methods = Queue.create () in
  List.iter api ~f:(function
    | Method { loc = _; comments = _; method_name; method_name_is_quoted = _; attributes }
      -> Queue.enqueue methods { Bopkit.Expanded_netlist.method_name; attributes }
    | Init_message { loc = _; comments = _; message } ->
      Queue.enqueue init_messages message);
  { Bopkit.Expanded_netlist.loc = external_block.loc
  ; name = external_block.name
  ; attributes = external_block.attributes
  ; init_messages = init_messages |> Queue.to_list
  ; methods = methods |> Queue.to_list
  ; command = eval_string ~parameters external_block.command
  }
;;
