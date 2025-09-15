(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type t [@@deriving sexp_of]

val create : len:int -> t

(** Blit the next value encoded on [len] bits into the destination array
    starting from [dst_pos]. When the internal counter has reached its maximum
    value, it starts again from 0. *)
val blit_next_value : t -> dst:Bit_array.t -> dst_pos:int -> unit
