(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type t =
  | VAR of string
  | CST of int
  | ADD of t * t
  | SUB of t * t
  | DIV of t * t
  | MULT of t * t
  | MOD of t * t
  | EXP of t * t
  | LOG of t
  | MIN of t * t
  | MAX of t * t
[@@deriving equal, sexp_of]

val vars : t -> string Appendable_list.t
val eval : t -> parameters:Parameters.t -> int Or_eval_error.t
val pp : t -> _ Pp.t
