(** A seven-segment display is a form of electronic display device for
    displaying decimal numerals

    For more information, see:
    https://en.wikipedia.org/wiki/Seven-segment_display

    This module implements the convention for driving the bits for each of the
    digit in a seven-segment display, from an array of bits of size 7. The
    convention used by this librarie is as follows:

    {[
      ---------
      --- 6 ---
      ||     ||
      |0     5|
      ||     ||
      ----1----
      ---------
      ||     ||
      |2     4|
      ||     ||
      ----3----
      ---------
    ]}

    Each display segment of index i must be lit if the i-th bit of its input is
    set to [true]. *)

(** Set the 7 segment bits of the supplied digit into the destination array from
    left to right, starting at from position [dst_pos]. This will raise on
    invalid input, or if the [dst] is too small. *)
val blit : digit:int -> dst:bool array -> dst_pos:int -> unit

(** For testing purposes, display the digit as a multi-line ascii string.*)
val to_ascii : digit:int -> string
