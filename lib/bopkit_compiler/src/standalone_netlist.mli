open! Core

(** One of the very first things we do as we process a project, is to resolve
    all "#include" constructs that we find in the project's files
    (recursively). We want to build a resulting netlist that is the
    aggregation of all the netlists that constitute a design. This aggregation
    is what is called here a [Standalone_netlist.t]. *)

type t =
  { filenames : string list
  ; parameters : Bopkit.Netlist.parameter list
  ; memories : Bopkit.Netlist.memory list
  ; external_blocks : Bopkit.Netlist.external_block list
  ; blocks : Bopkit.Netlist.block list
  }
[@@deriving sexp_of]

val empty : t
val concat : t list -> t
