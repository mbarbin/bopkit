(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

val pass
  :  Bopkit.Netlist.external_block
  -> parameters:Bopkit.Parameters.t
  -> Bopkit.Expanded_netlist.external_block
