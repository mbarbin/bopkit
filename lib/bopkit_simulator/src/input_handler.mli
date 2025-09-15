(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** This is the module responsible for reading the input of the circuit at each
    cycle and feeding it to the rest of the simulation. Creating a [t]
    requires the simulation config, so it is possible to tweak the behavior of
    this module from the command line. For example, replacing the reading of
    the input from stdin by the result of a counter. *)

type t

val create : config:Config.t -> expected_input_length:int -> t

(** This function is called at each cycle to mutate the input of the circuit. It
    raises [End_of_file] if there are no more chars to read on [stdin]. *)
val blit_input : t -> dst:bool array -> unit
