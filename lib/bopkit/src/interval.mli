open! Core

(** [from] and [to_] are included in the interval. [from] may be smaller than,
    equal to, or greater than [to_]. *)
type t =
  { from : int
  ; to_ : int
  }
[@@deriving equal, sexp_of]

val singleton : int -> t
val expand : t -> f:(int -> 'a) -> 'a list

(** When multiple indexes are used in sequence, the development goes from right
    to left, that is:

   {v
     a:[2]:[3] --->  a[0][0], a[0][1], a[0][2], a[1][0], a[1][1], a[1][2]
   v}
*)
val expand_list : t list -> f:(int -> 'a) -> 'a list list
