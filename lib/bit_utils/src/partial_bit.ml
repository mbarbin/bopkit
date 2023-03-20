open! Core

type t = bool option [@@deriving compare, equal, quickcheck, sexp_of]

let conflicts t ~with_:bool =
  match t with
  | None -> false
  | Some b -> not (Bool.equal b bool)
;;
