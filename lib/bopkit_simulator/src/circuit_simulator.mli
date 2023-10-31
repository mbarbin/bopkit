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

module One_cycle_result : sig
  type t =
    | Continue
    | Quit
end

(** Run through one clock cycle of the simulation. Start by calling [blit_input]
    to fill it with the input values for that cycle. If the cycle encounters a
    condition under which the simulation cannot continue, it will return
    [Quit], otherwise [Continue]. If an unexpected condition is encountered,
    errors will be added to t's error log. *)
val one_cycle
  :  t
  -> blit_input:(dst:Bit_array.t -> unit)
  -> output_handler:(input:Bit_array.t -> output:Bit_array.t -> unit)
  -> One_cycle_result.t
