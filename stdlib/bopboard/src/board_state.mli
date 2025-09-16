(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Pure state module for bopboard - SDL-free and thread-safe.

    This module contains the essential state for bopboard operation without
    any SDL dependencies, making it safe to access from any thread. It also
    provides all the bopkit block methods that operate on this state. *)

(** Pure state type without SDL dependencies *)
type t

(** Create initial state with specified array sizes *)
val create : num_lights:int -> num_switches:int -> num_pushes:int -> t

(** Direct array access for GUI thread. *)

val needs_redraw : t -> bool ref
val lights : t -> bool array
val switches : t -> bool array
val pushes : t -> bool array

(** Main thread to act as external bopkit node. *)

val bopkit_block : t -> Bopkit_block.t
