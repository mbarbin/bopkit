type t =
  | Cds
  | Cds_split_registers
  | Cds_topological_sort
  | Expanded_blocks
  | Expanded_netlist
  | Expanded_nodes
  | External_blocks
  | Includes
  | Memories
  | Parameters
[@@deriving enumerate, equal, sexp_of]

let to_string t =
  match sexp_of_t t with
  | Atom s -> s
  | List _ -> assert false
;;
