(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** In bopkit bdd synthesized blocks, there are 3 different classes of signals:

    -the input
    -the output
    -internal signals used for sharing intermediate results.

    The code that prints out the block is free to use any representation it
    chooses for them, as long as they stay distinct. *)

type t =
  | Input of int
  | Output of int
  | Internal of int
[@@deriving compare, equal, hash, sexp_of]
