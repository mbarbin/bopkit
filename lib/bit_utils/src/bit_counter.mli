open! Core

type t [@@deriving sexp_of]

val create : len:int -> t

(** Blit the next value encoded on [len] bits into the destination array
    starting from [dst_pos]. When the internal counter has reached its maximum
    value, it starts again from 0. *)
val blit_next_value : t -> dst:Bit_array.t -> dst_pos:int -> unit
