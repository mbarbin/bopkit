open! Core

type output =
  { inline_external_blocks : Bopkit.Expanded_netlist.external_block list
  ; blocks : Bopkit.Expanded_netlist.block list
  }

val pass
  :  Bopkit.Netlist.block list
  -> error_log:Error_log.t
  -> primitives:Primitive.env
  -> parameters:Bopkit.Parameters.t
  -> output
