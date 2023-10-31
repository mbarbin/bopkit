(** The visa microprocessor communicates with external devices thanks to
    dedicated export ports called the output device. *)

type t [@@deriving equal, sexp_of]

val create : len:int -> t
val length : t -> int

(** [address] is expected to be within [0,len-1]. Only the least significant
    bits of [value] are used. *)
val set : t -> address:int -> value:int -> unit

val to_string : t -> string
