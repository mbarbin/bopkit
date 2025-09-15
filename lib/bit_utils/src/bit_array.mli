(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** In bopkit, bool arrays have many uses, including saving or reading the
    contents of memory-units from files, exchanging the value of buses between
    external blocks, printing block outputs to stdout, etc.

    In contexts where bits are encoded as human readable characters, [false] is
    the bit '0' and [true] is the bit '1'. When saved to files, bits are stored
    using their human readable characters. *)

type t = bool array [@@deriving compare, equal, quickcheck, sexp_of]

(** Builds a [t] by only looking at the characters '0' and '1' from a multi
    lines string. Comments are supported and start with '//', in which case
    all remaining characters until the end of the current line are ignored.

    The parsed contents is allowed to contain separator characters for better
    readability ('|' or space).

    For example:

    {v
     // This is a comment, these chars are ignored: 001010
     00|01 // On this line, only the chars "0001" are read, the '|' is ignored
     // The following line does not have a comment, and the space is ignored
     00 10
    v} *)
val of_01_chars_in_string : string -> t

(** Creates a string of bits made of '0' (false) and '1' (true). *)
val to_string : t -> string

(** Concat all the value read on all the lines from a file, using the function
    [of_01_chars_in_string]. *)
val of_text_file : path:Fpath.t -> t

(** Write a bunch of '0' and '1' to a file, ending with a newline character.
    This erases the previous contents of the file if it existed. *)
val to_text_file : t -> path:Fpath.t -> unit

val to_text_channel : t -> Out_channel.t -> unit

(** [to_int t] returns the binary value encoded by [t], with the least
    significant bits to the left of the array. *)
val to_int : t -> int

(** Taking the length of the array as a reference for the architecture,
    [to_signed_int t] returns the signed binary value encoded by [t] with the
    least significant bits to the left. *)
val to_signed_int : t -> int

(** [blit_int ~src:i ~dst:t] changes the bits of [t] by setting them to the
    binary encoding of the integer value [i]. This operation is done taking
    the length of the array as a reference for the architecture, so in
    practice this means modulo (2^n) where n is the length of [t]. [i] is
    allowed to be null or negative - in all cases [blit_int] behaves as if
    [~src:(i % 2^n)] was supplied. *)
val blit_int : src:int -> dst:t -> unit

(** [blit_init ~dst:t ~f] will reset the contents of [t] with values returned by
    [f], applied to the integers [0..n-1] in increasing order (n being the
    length of [t]). This is sort of an "in place" version of [Array.init], to
    be used when you want to change an existing array rather than returning a
    new one. *)
val blit_init : dst:t -> f:(int -> bool) -> unit

module Short_sexp : sig
  (** Creates an atom with bits made of '0' (false) and '1' (true). *)
  type nonrec t = t [@@deriving sexp_of]
end
