open! Core

module Value = struct
  type t =
    | Int of int
    | String of string
  [@@deriving compare, equal, hash, sexp_of]

  let to_syntax = function
    | Int d -> Int.to_string d
    | String s -> sprintf "%S" s
  ;;
end

type t =
  { name : string
  ; value : Value.t
  }
[@@deriving equal, sexp_of]
