(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Module to create and update an OCaml Graphics with a 7-segment display for a
    digital watch. *)

type t

(** Open an OCaml Graphics windows with a new 7-segment displays drawn in it. *)
val init : unit -> t

(** Update the display according to the signal provided. See
    [Seven_segment_code] for the details as for what the signal of each digit
    should be. The signal array expects to be of size 42, that encodes for 6
    digits of 7-segment each.

    The order of the digits in the signal array is expected to be from left to
    right compared to the order of the digits as seen in the display, as in:
    01:23:45 *)
val update : t -> bool array -> unit

module Decoded : sig
  type t =
    { hour : int
    ; minute : int
    ; second : int
    }
  [@@deriving equal, sexp_of]

  val to_string : t -> string
  val blit : t -> dst:bool array -> unit
end

(** For tests and or displaying the information in a terminal, it may be useful
    to be able to decode a signal array, using the same input convention. *)
val decode : bool array -> Decoded.t
