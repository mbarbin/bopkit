(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t = bool option [@@deriving compare, equal, quickcheck, sexp_of]

let conflicts t ~with_:bool =
  match t with
  | None -> false
  | Some b -> not (Bool.equal b bool)
;;
