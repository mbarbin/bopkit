(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type output =
  { rom_memories : Bit_matrix.t array
  ; memories : Bopkit.Expanded_netlist.memory array
  ; primitives : Primitive.env
  }

val pass : Bopkit.Netlist.memory list -> parameters:Bopkit.Parameters.t -> output
