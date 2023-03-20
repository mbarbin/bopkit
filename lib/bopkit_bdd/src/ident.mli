open! Core
open! Import

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
