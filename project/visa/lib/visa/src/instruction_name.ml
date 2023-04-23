open! Core

type t =
  | NOP
  | SLEEP
  | ADD
  | AND
  | SWC
  | CMP
  | NOT
  | GOF
  | JMP
  | JMN
  | JMZ
  | STORE
  | WRITE
  | LOAD
[@@deriving enumerate, equal, sexp_of]

let to_string t =
  match sexp_of_t t with
  | List _ -> assert false
  | Atom atom -> String.lowercase atom
;;
