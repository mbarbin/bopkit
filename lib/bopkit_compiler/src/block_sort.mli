open! Import

(** Topological sort for Blocks. *)

val sort : Bopkit.Netlist.block list -> error_log:Error_log.t -> Bopkit.Netlist.block list
