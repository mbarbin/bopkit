(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Sometimes some of the bits of a given computation are not specified
    (sometimes called "outputs with bit don't care"). This modules allows to
    represent such cases.

    In contexts where bits don't care are encoded as human readable characters,
    we use the star char '*' to designate an unspecified bit. *)

type t = Partial_bit.t array [@@deriving compare, equal, quickcheck, sexp_of]

(** Builds a [t] by only looking at the characters '0', '1' and '*' from a
    string, and ignores all the other characters. *)
val of_01star_chars_in_string : string -> t

(** Creates a string made of '0', '1' and '*'. *)
val to_string : t -> string

(** See {!val:Bit_array.of_text_file}. *)
val of_text_file : path:Fpath.t -> t

(** Save to disk, ends with a newline. *)
val to_text_file : t -> path:Fpath.t -> unit

val to_text_channel : t -> Out_channel.t -> unit

(** Check whether a partial specification has conflicts with a fully specified
    value. Unspecified bits can take whatever value in the specified value. If
    the values do not have the same size, only compare up to the smallest of
    the two. *)
val conflicts : t -> with_:Bit_array.t -> bool
