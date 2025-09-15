(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** A type used to manipulate the errors that occur when evaluating parameters,
    string_with_vars, etc. *)

type t =
  | Free_variable of
      { name : string
      ; candidates : string list
      }
  | Type_clash of { message : string }
  | Syntax_error of { in_ : string }
[@@deriving sexp_of]

val raise : t -> loc:Loc.t -> _
