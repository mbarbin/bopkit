open! Core

(** Extending [Bit_array] for arrays of 2 dimensions. For examples,
    loading/saving contents of memories. *)

type t = Bit_array.t array [@@deriving compare, equal, sexp_of]

(** Create a new matrix initiated with the results of the function [f] called
    from left to right with indexes increasing from 0 to n-1. This loops along
    the dimx dimension first, and dimy second, which means that all the [ys]
    for a given [x] are consecutive). *)
val init_matrix_linear : dimx:int -> dimy:int -> f:(int -> 'a) -> 'a array array

(** Initiate a new matrix by taking the contents from a linear bit array. If the
    input is too long, only the useful prefix is used. If the input is too
    short, the rest of the bits is set to [false]. *)
val of_bit_array : dimx:int -> dimy:int -> Bit_array.t -> t

(** See {!val:Bit_array.of_text_file}. *)
val of_text_file : dimx:int -> dimy:int -> filename:string -> t

(** Save it to disk. To make things more readable, write things line by line in
    the file (along the dimx dimension). *)
val to_text_file : t -> filename:string -> unit

val to_text_channel : t -> Out_channel.t -> unit

(** {1 Dimensions} *)

val dimx : t -> int
val dimy : t -> int
