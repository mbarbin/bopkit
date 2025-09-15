(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type t =
  | NOP
  | SLEEP
  | ADD
  | AND
  | SWC
  | CMP
  | NOT
  | GOF
  | JMP
  | JMN
  | JMZ
  | STORE
  | WRITE
  | LOAD
[@@deriving enumerate, equal, sexp_of]

val to_string : t -> string
