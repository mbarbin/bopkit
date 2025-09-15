(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Block_node :
  Bopkit_topological_sort.Node with type t = Bopkit.Netlist.block and type key = string =
struct
  type t = Bopkit.Netlist.block
  type key = string

  let key (t : t) =
    match t.name with
    | Standard { name } -> name
    | Parametrized { name; _ } -> Printf.sprintf "%s[]" name
  ;;

  let parents (fct : t) =
    let nodes = fct.nodes in
    let functional_args =
      match fct.name with
      | Parametrized t -> t.functional_parameters
      | Standard _ -> []
    in
    let rec aux_call : Bopkit.Netlist.call -> _ = function
      | External_block _ | External_command _ -> Appendable_list.empty
      | Block { name; arguments; functional_arguments } ->
        if List.mem functional_args name ~equal:String.equal
        then Appendable_list.empty
        else
          Appendable_list.singleton
            (match arguments, functional_arguments with
             | [], [] -> name
             | _ -> Printf.sprintf "%s[]" name)
    and aux_imbrication : Bopkit.Netlist.nested_inputs -> _ = function
      | Nested_node { loc = _; comments = _; call; inputs } ->
        Appendable_list.concat (aux_call call :: List.map inputs ~f:aux_imbrication)
      | Variables _ -> Appendable_list.empty
    and aux_node : Bopkit.Netlist.node Bopkit.Control_structure.t -> _ = function
      | Node { loc = _; comments = _; call; inputs; outputs = _ } ->
        Appendable_list.concat (aux_call call :: List.map inputs ~f:aux_imbrication)
      | For_loop { nodes = node_list; _ } ->
        List.map node_list ~f:aux_node |> Appendable_list.concat
      | If_then_else { then_nodes = node_then; else_nodes = node_else; _ } ->
        Appendable_list.append
          (List.map node_then ~f:aux_node |> Appendable_list.concat)
          (List.map node_else ~f:aux_node |> Appendable_list.concat)
    in
    List.map nodes ~f:aux_node |> Appendable_list.concat
  ;;
end

let sort blocks = Bopkit_topological_sort.sort (module Block_node) (module String) blocks
