open! Core

type t [@@deriving equal, sexp_of]

val make : attached_to:Lexing.position -> t
val none : t
val value : t -> Comment.t list
val is_empty : t -> bool
