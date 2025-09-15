(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type t

val create : colors:Colors.t -> size:int -> x:int -> y:int -> t
val init : t -> unit
val update : t -> src:bool array -> src_pos:int -> unit
