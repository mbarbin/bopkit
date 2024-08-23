type output =
  { rom_memories : Bit_matrix.t array
  ; memories : Bopkit.Expanded_netlist.memory array
  ; primitives : Primitive.env
  }

val pass : Bopkit.Netlist.memory list -> parameters:Bopkit.Parameters.t -> output
