(** A type to regroup an identifier for various passes of the bopkit compiler.
    This allows for example to toggle debug values. *)

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

val to_string : t -> string
