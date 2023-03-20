open! Core

(** A list of elements that supports constant time append operations.

    This is similar to [core_extended.appendable_list] but reduced to the small
    need of bopkit. *)

type +'a t

val empty : 'a t
val of_list : 'a list -> 'a t
val append : 'a t -> 'a t -> 'a t
val concat : 'a t list -> 'a t
val concat_map : 'a list -> f:('a -> 'b t) -> 'b t
val iter : 'a t -> f:('a -> unit) -> unit
val to_list : 'a t -> 'a list
