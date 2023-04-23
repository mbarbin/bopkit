open! Core

type t =
  | R0
  | R1
[@@deriving equal, sexp_of]

val to_string : t -> string
