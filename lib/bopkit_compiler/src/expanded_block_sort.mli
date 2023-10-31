open! Import

(** Topological sort for Blocks. *)

val sort
  :  Bopkit.Expanded_netlist.block list
  -> error_log:Error_log.t
  -> Bopkit.Expanded_netlist.block list
