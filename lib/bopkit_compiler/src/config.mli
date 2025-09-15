(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type t

val default : t
val arg : t Command.Arg.t

(** {1 Getters} *)

val optimize_cds : t -> bool
val print_pass_output : t -> pass_name:Pass_name.t -> bool
val parameters_overrides : t -> Bopkit.Parameters.t
val main : t -> string option
