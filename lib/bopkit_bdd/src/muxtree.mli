(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type t =
  | Constant of bool option
  | Signal of Ident.t
  | Not_signal of Ident.t
  | Mux of
      { input : int
      ; vdd : t
      ; gnd : t
      }
[@@deriving compare, equal, hash, sexp_of]

include Comparator.S with type t := t

(** Operate immediate simplifications on [t] if able. *)
val normalize : t -> t

(** Construct the non optimized trees from a boolean function [f] encoded as a
    partial bit matrix. The returned list [r] has the size of the words
    returned by [f], with [r.(i)] being the [i-th] bit of the output. *)
val of_partial_bit_matrix : Partial_bit_matrix.t -> t list

val number_of_gates : t -> int
