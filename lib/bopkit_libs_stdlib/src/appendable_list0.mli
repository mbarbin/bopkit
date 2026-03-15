(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(*_ Adapted from https://github.com/mbarbin/appendable-list. *)
(*_ Originally from Jane Street's core_extended. See third-party-license/. *)

(** Appendable lists: constant-time append, O(n) conversion to list. *)

type +'a t

val empty : _ t
val singleton : 'a -> 'a t
val cons : 'a -> 'a t -> 'a t
val append : 'a t -> 'a t -> 'a t
val of_list : 'a list -> 'a t
val concat : 'a t list -> 'a t
val to_list : 'a t -> 'a list
val iter : 'a t -> f:('a -> unit) -> unit
