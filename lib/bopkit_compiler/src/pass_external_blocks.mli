open! Core

val pass
  :  Bopkit.Netlist.external_block
  -> error_log:Error_log.t
  -> parameters:Bopkit.Parameters.t
  -> Bopkit.Expanded_netlist.external_block
