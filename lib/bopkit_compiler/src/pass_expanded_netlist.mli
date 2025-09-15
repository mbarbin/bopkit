(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type output =
  { inline_external_blocks : Bopkit.Expanded_netlist.external_block list
  ; blocks : Bopkit.Expanded_netlist.block list
  }

val pass
  :  Bopkit.Netlist.block list
  -> primitives:Primitive.env
  -> parameters:Bopkit.Parameters.t
  -> output
