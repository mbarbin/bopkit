open! Core
open! Import

type t [@@deriving sexp_of]

(** Output a bloc using Bopkit concrete syntax. The resulting simulation of the
    Bopkit block is equal to the boolean function that the block encodes. *)
val pp : Format.formatter -> t -> unit

(** Create a bloc from a computation where each output is computed by a
    dedicated muxtree. *)
val of_muxtrees : ?block_name:string -> Muxtree.t list -> input_size:int -> t

(** Create a bloc from a computation where internal tree nodes have been shared. *)
val of_muxlist : ?block_name:string -> Muxlist.t -> input_size:int -> t

(** Count all gates that cannot be immediately simplified (such as id nodes). *)
val number_of_gates : t -> int
