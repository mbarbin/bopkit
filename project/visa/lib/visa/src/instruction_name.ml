(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

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

let to_string t =
  match sexp_of_t t with
  | List _ -> assert false
  | Atom atom -> String.lowercase atom
;;
