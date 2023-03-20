open! Core
open! Import

module Topo_block :
  Bopkit_topological_sort.Node with type t = Bopkit.Netlist.block and type key = string =
struct
  type t = Bopkit.Netlist.block
  type key = string

  let key (t : t) =
    match t.name with
    | Standard { name } -> name
    | Parametrized { name; _ } -> Printf.sprintf "%s[]" name
  ;;

  let parents (fct : t) ~error_log:_ =
    let nodes = fct.nodes in
    let functional_args =
      match fct.name with
      | Parametrized t -> t.functional_parameters
      | Standard _ -> []
    in
    let rec aux_call : Bopkit.Netlist.call -> _ = function
      | External_block _ | Pipe _ -> Appendable_list.empty
      | Block { name; arguments = exp_list; functional_arguments = arg_list } ->
        if List.mem functional_args name ~equal:String.equal
        then Appendable_list.empty
        else
          Appendable_list.of_list
            (match exp_list, arg_list with
             | [], [] -> [ name ]
             | _ -> [ Printf.sprintf "%s[]" name ])
    and aux_imbrication : Bopkit.Netlist.nested_inputs -> _ = function
      | Nested_node { loc = _; comments = _; call = portee; inputs = imb_list } ->
        Appendable_list.append
          (aux_call portee)
          (Appendable_list.concat_map imb_list ~f:aux_imbrication)
      | Variables _ -> Appendable_list.empty
    and aux_node : Bopkit.Netlist.node Bopkit.Control_structure.t -> _ = function
      | Node { loc = _; comments = _; call = portee; inputs = imbric_list; outputs = _ }
        ->
        Appendable_list.append
          (aux_call portee)
          (Appendable_list.concat_map imbric_list ~f:aux_imbrication)
      | For_loop { nodes = node_list; _ } ->
        Appendable_list.concat_map node_list ~f:aux_node
      | If_then_else { then_nodes = node_then; else_nodes = node_else; _ } ->
        Appendable_list.append
          (Appendable_list.concat_map node_then ~f:aux_node)
          (Appendable_list.concat_map node_else ~f:aux_node)
    in
    Appendable_list.concat_map nodes ~f:aux_node
  ;;
end

let sort blocks ~error_log =
  Bopkit_topological_sort.sort (module Topo_block) (module String) blocks ~error_log
;;
