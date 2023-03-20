open! Core
open! Import

module Topo_block :
  Bopkit_topological_sort.Node
    with type t = Bopkit.Expanded_netlist.block
     and type key = string = struct
  type t = Bopkit.Expanded_netlist.block
  type key = string

  let key (t : t) = t.name

  let parents (fct : t) ~error_log:_ =
    let nodes = fct.nodes in
    let rec aux_call : Bopkit.Expanded_netlist.call -> _ = function
      | External_block _ -> Appendable_list.empty
      | Block { name } -> Appendable_list.of_list [ name ]
    and aux_node : Bopkit.Expanded_netlist.node -> _ = function
      | { loc = _; call; inputs = _; outputs = _ } -> aux_call call
    in
    Appendable_list.concat_map nodes ~f:aux_node
  ;;
end

let sort blocks ~error_log =
  Bopkit_topological_sort.sort (module Topo_block) (module String) blocks ~error_log
;;
