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

val to_string : t -> string
