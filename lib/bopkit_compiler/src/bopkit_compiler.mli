open! Import
module Expanded_block = Expanded_block
module Primitive = Primitive

module Config : sig
  type t

  val default : t
  val param : t Command.Param.t
end

val create_block
  :  Bopkit.Expanded_netlist.block
  -> error_log:Error_log.t
  -> primitives:Primitive.env
  -> env:Expanded_block.env
  -> Expanded_block.t

val expand_netlist
  :  path:Fpath.t
  -> error_log:Error_log.t
  -> config:Config.t
  -> (Primitive.env * Bopkit.Expanded_netlist.t) Or_error.t

val circuit_of_netlist
  :  path:Fpath.t
  -> error_log:Error_log.t
  -> config:Config.t
  -> Bopkit_circuit.Circuit.t Or_error.t
