type t =
  | Input of int
  | Output of int
  | Internal of int
[@@deriving compare, equal, hash, sexp_of]
