(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Once a bopkit project has been converted to a circuit, this module allows to
    simulate its execution. By default, the simulation runs in a loop and can
    be interrupted with a SigInt. You can also specify via the [Config.t] a
    finite number of cycles.

    Inputs are read from stdin, and outputs produced on stdout, using the chars
    '0' and '1' to encode for signal values. *)

module Config : sig
  type t

  val default : t
  val arg : t Command.Arg.t
end

(** Run cycles of the simulation in a loop. See [Config.t] to toggle various
    settings. *)
val run : circuit:Bopkit_circuit.Circuit.t -> config:Config.t -> unit
