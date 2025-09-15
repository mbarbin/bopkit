(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Interpreter for a bopkit process program. *)

(** Given an architecture parameter and an input program, interpret its
    evaluation - reading inputs from stdin and writing output to stdout in a
    loop until stdin is closed. *)
val run_program : architecture:int -> program:Bopkit_process.Program.t -> unit Or_error.t
