(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Module to create and update an OCaml Graphics with a 7-segment display for a
    digital calendar. *)

type t

(** Open an OCaml Graphics windows with a new 7-segment displays drawn in it. *)
val init : unit -> t

(** Update the display according to the signal provided. See
    [Seven_segment_code] for the details as for what the signal of each digit
    should be. The signal array expects to be of size 91, that encodes for 6
    time digits and 6 date digits of 7-segment each. The missing 91-84=7 bits
    are currently unused and are place holder to indicate the name of the day
    of the week (Mon-Sun).

    The order of the digits in the signal array is as follows:

    Time digits "HH:MM:SS" are given in this order: "54:32:10" from pos:0.
    Date digits "DD:MM:YY" are given in this order: "10:32:54" from pos:49. *)
val update : t -> bool array -> unit

module Decoded : sig
  type t =
    { hour : int
    ; minute : int
    ; second : int
    ; day : int
    ; month : int
    ; year : int
    }
  [@@deriving equal, sexp_of]

  val to_string : t -> string
  val blit : t -> dst:bool array -> unit
end

(** For tests and or displaying the information in a terminal, it may be useful
    to be able to decode a signal array, using the same input convention. *)
val decode : bool array -> Decoded.t
