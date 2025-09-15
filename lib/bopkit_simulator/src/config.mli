(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** This type allows the user to tweak some behavior of the simulator from the
    command line. For example, deciding whether to print the inputs on stdout,
    whether to stop the simulation after some number of cycles, etc. *)

type t

val default : t
val arg : t Command.Arg.t

(** {1 Getters} *)

val num_cycles : t -> expected_input_length:int -> int option
val counter_input : t -> bool

module Output_kind : sig
  type t =
    | Default of { output_only_on_change : bool }
    | As_external_block
    | Show_input
end

val output_kind : t -> Output_kind.t
