let map_index index : Bopkit.Netlist.index =
  match (index : Bopkit.Expanded_netlist.index) with
  | Interval (0, n) when n > 0 -> Segment (CST (n - 1))
  | Interval (n, 0) when n < 0 -> Segment (CST (-n + 1))
  | Interval (a, b) -> Interval (CST a, CST b)
  | Index i -> Index (CST i)
;;

let map_variable variable : Bopkit.Netlist.variable =
  match (variable : Bopkit.Expanded_netlist.variable) with
  | Signal { name } -> Signal { name }
  | Bus { loc; name; indexes } ->
    Bus { loc; name; indexes = List.map indexes ~f:map_index }
  | Internal i -> Signal { name = Printf.sprintf "#%d#" i }
;;

let map_variables { Bopkit.Expanded_netlist.original_grouping; _ } =
  List.map original_grouping ~f:map_variable
;;

let map_call call : Bopkit.Netlist.call =
  match (call : Bopkit.Expanded_netlist.call) with
  | Block { name } -> Block { name; arguments = []; functional_arguments = [] }
  | External_block { name; method_name; external_arguments } ->
    External_block
      { name
      ; method_name
      ; method_name_is_quoted = false
      ; external_arguments
      ; output_size = Inferred
      }
;;

let map_node { Bopkit.Expanded_netlist.loc; call; inputs; outputs } =
  { Bopkit.Netlist.loc
  ; comments = Bopkit.Comments.none
  ; call = map_call call
  ; inputs =
      [ Variables
          { loc; comments = Bopkit.Comments.none; variables = map_variables inputs }
      ]
  ; outputs = map_variables outputs
  }
;;

let map_block
      { Bopkit.Expanded_netlist.loc
      ; name
      ; attributes
      ; inputs
      ; outputs
      ; unused_variables
      ; nodes
      }
  =
  { Bopkit.Netlist.loc
  ; head_comments = Bopkit.Comments.none
  ; tail_comments = Bopkit.Comments.none
  ; name = Standard { name }
  ; attributes
  ; inputs = map_variables inputs
  ; outputs = map_variables outputs
  ; unused_variables = map_variables unused_variables
  ; nodes = List.map nodes ~f:(fun node -> Bopkit.Control_structure.Node (map_node node))
  }
;;

let pp_block b = Netlist.pp_block (map_block b)
