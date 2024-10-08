module Expanded_block_node :
  Bopkit_topological_sort.Node
  with type t = Bopkit.Expanded_netlist.block
   and type key = string = struct
  type t = Bopkit.Expanded_netlist.block
  type key = string

  let key (t : t) = t.name

  let parents (fct : t) =
    let nodes = fct.nodes in
    let rec aux_call : Bopkit.Expanded_netlist.call -> _ = function
      | External_block _ -> Appendable_list.empty
      | Block { name } -> Appendable_list.singleton name
    and aux_node : Bopkit.Expanded_netlist.node -> _ = function
      | { loc = _; call; inputs = _; outputs = _ } -> aux_call call
    in
    List.map nodes ~f:aux_node |> Appendable_list.concat
  ;;
end

let sort blocks =
  Bopkit_topological_sort.sort (module Expanded_block_node) (module String) blocks
;;
