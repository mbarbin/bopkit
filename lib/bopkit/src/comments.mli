(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type t [@@deriving equal, sexp_of]

val make : attached_to:Lexing.position -> t
val none : t
val value : t -> Comment.t list
val is_empty : t -> bool
