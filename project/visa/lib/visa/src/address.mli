open! Core

type t [@@deriving equal, sexp_of]

val of_int : int -> t
val to_int : t -> int
val to_string : t -> string
