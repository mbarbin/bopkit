open! Core

(** The circuit holds a [Cds.t] along with information required to fire the
    computation of gates that are not entirely combinatorial, such as memories
    and external nodes. *)

type t

val of_circuit : circuit:Bopkit_circuit.Circuit.t -> error_log:Error_log.t -> t

(** Access the input and output of the simulated circuit. *)

val input : t -> Bit_array.t
val output : t -> Bit_array.t

(** Initialize the circuit. In particular, open all external processes. *)
val init : t -> unit

(** Cleanly end the simulation. In particular, close all external processes. *)
val quit : t -> unit

(** Run through one clock cycle of the simulation. When encountering the input
    node, calls [blit_input] to fill it with the input values for that cycle.
*)
val one_cycle : t -> blit_input:(dst:bool array -> unit) -> unit
