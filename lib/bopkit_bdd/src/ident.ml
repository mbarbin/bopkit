open! Core
open! Import

type t =
  | Input of int
  | Output of int
  | Internal of int
[@@deriving compare, equal, hash, sexp_of]
