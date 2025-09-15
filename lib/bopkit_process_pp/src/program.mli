(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** A code formatter for programs, e.g. to be used by [dune fmt]. *)

type t = Bopkit_process.Program.t

val pp : t -> _ Pp.t
