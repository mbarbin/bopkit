(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Create a new [Expanded_block.t] from its expanded netlist representation,
    while performing some checks. *)
val create_block
  :  Bopkit.Expanded_netlist.block
  -> primitives:Primitive.env
  -> env:Expanded_block.env
  -> Expanded_block.t

val create_env
  :  Bopkit.Expanded_netlist.block list
  -> primitives:Primitive.env
  -> Expanded_block.env

val global_cycle_hints : (Expanded_block.t * string list) Queue.t
