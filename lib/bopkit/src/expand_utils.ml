open! Core

let interval_of_index (index : Expanded_netlist.index) =
  match index with
  | Index i -> Interval.singleton i
  | Interval (from, to_) -> { Interval.from; to_ }
;;

let expand_indexes (indexes : Expanded_netlist.index list) ~f =
  let intervals = List.map indexes ~f:interval_of_index in
  Interval.expand_list intervals ~f |> List.map ~f:(fun li -> String.concat li)
;;

let eval_index (index : Netlist.index) ~loc ~error_log ~parameters
  : Expanded_netlist.index
  =
  let eval_expr expr =
    Arithmetic_expression.eval expr ~parameters |> Or_eval_error.ok_exn ~error_log ~loc
  in
  match index with
  | Index e -> Index (eval_expr e)
  | Interval (a, b) -> Interval (eval_expr a, eval_expr b)
  | Segment e ->
    let e = eval_expr e in
    if e < 0 then Interval (-e - 1, 0) else Interval (0, e - 1)
;;

let eval_variable (variable : Netlist.variable) ~error_log ~parameters
  : Expanded_netlist.variable
  =
  match variable with
  | Signal { name } -> Signal { name }
  | Bus { loc; name; indexes } ->
    let indexes =
      List.map indexes ~f:(fun index -> eval_index index ~loc ~error_log ~parameters)
    in
    Bus { loc; name; indexes }
;;

let expand_const_variable (variable : Expanded_netlist.variable) =
  match variable with
  | Signal { name } -> [ name ]
  | Internal i -> [ sprintf "#%d#" i ]
  | Bus { loc = _; name; indexes } ->
    let suffixes = expand_indexes indexes ~f:(fun i -> sprintf "[%d]" i) in
    List.map suffixes ~f:(fun suffix -> name ^ suffix)
;;

let expand_variable (variable : Netlist.variable) ~error_log ~parameters =
  expand_const_variable (eval_variable variable ~error_log ~parameters)
;;
