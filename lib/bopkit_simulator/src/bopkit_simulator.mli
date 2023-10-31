(** Once a bopkit project has been converted to a circuit, this module allows to
    simulate its execution. By default, the simulation runs in a loop and can
    be interrupted with a SigInt. You can also specify via the [Config.t] a
    finite number of cycles.

    Inputs are read from stdin, and outputs produced on stdout, using the chars
    '0' and '1' to encode for signal values. *)

module Config : sig
  type t

  val default : t
  val param : t Command.Param.t
end

(** Run cycles of the simulation in a loop. See [Config.t] to toggle various
    settings. *)
val run
  :  circuit:Bopkit_circuit.Circuit.t
  -> error_log:Error_log.t
  -> config:Config.t
  -> unit
