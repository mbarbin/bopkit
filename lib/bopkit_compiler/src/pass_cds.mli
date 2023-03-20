open! Core

(** The pass that builds the cds, from the expanded_nodes representation. *)

val pass : Expanded_nodes.t -> Bopkit_circuit.Cds.t
