open! Core

(** This data structure helps during the transition from the [Expanded_nodes.t]
    representation to the [Cds.t]. It keeps track of all the positions at which
    a variable is used as an input, which in turn helps create the output_wires
    for that variable on the gate where that variable is an output.

    For example, let's keep track of the variable "a" in the example below:

    {v
      a, b, c = gate0 ();
      d, e, f = gate1 (a); <-- Adding { gate_index = 1; input_index = 0 }
      g = gate2 (d, e, a); <-- Adding { gate_index = 2; input_index = 2 }
    v}

    At the end, looking up "a" in the structure will return all output_wire that
    were added, which allows to fill in the output_wire of output "a" in the
    gate0. *)

type output_wire = Bopkit_circuit.Output_wire.t
type t

val empty : t
val add : t -> key:string -> data:output_wire -> t

(** The returned list is sorted according to [Output_wire.compare]. *)
val find_or_empty : t -> key:string -> output_wire list
