module Expanded_block = Expanded_block
module Primitive = Primitive

module Config : sig
  type t

  val default : t
  val arg : t Command.Arg.t
end

val create_block
  :  Bopkit.Expanded_netlist.block
  -> primitives:Primitive.env
  -> env:Expanded_block.env
  -> Expanded_block.t

val expand_netlist
  :  path:Fpath.t
  -> config:Config.t
  -> Primitive.env * Bopkit.Expanded_netlist.t

val circuit_of_netlist : path:Fpath.t -> config:Config.t -> Bopkit_circuit.Circuit.t
