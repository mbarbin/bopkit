(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t =
  | R0
  | R1
[@@deriving equal, sexp_of]

let to_string t =
  match sexp_of_t t with
  | List _ -> assert false
  | Atom s -> s
;;
