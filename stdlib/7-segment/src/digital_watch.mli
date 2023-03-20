(** Module to create and update an OCaml graphics with a 7-segment display for a
    digital watch. *)

open! Core

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
