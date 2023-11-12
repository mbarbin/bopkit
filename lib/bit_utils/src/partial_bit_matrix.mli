(** Extending [Partial_bit_array] for arrays of 2 dimensions. *)

type t = Partial_bit_array.t array [@@deriving compare, equal, sexp_of]

(** Initiate a new matrix by taking the contents from a linear partial bit
    array. If the input is too long, only the useful prefix is used. If the
    input is too short, the rest of the bits is set to [None]. *)
val of_partial_bit_array : dimx:int -> dimy:int -> Partial_bit_array.t -> t

(** See {!val:Partial_bit_array.of_text_file}. *)
val of_text_file : dimx:int -> dimy:int -> path:Fpath.t -> t

val to_text_file : t -> path:Fpath.t -> unit
val to_text_channel : t -> Out_channel.t -> unit
