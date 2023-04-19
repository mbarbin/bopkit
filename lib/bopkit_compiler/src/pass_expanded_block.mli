open! Core

(** Create a new [Expanded_block.t] from its expanded netlist representation,
    while performing some checks. *)
val create_block
  :  Bopkit.Expanded_netlist.block
  -> error_log:Error_log.t
  -> primitives:Primitive.env
  -> env:Expanded_block.env
  -> Expanded_block.t

val create_env
  :  Bopkit.Expanded_netlist.block list
  -> error_log:Error_log.t
  -> primitives:Primitive.env
  -> Expanded_block.env

val global_cycle_hints : (Expanded_block.t * string list) Queue.t
