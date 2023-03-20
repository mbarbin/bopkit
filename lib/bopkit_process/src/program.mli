open! Core

(** A process program, as read and returned by the parser. *)

module Argument : sig
  type t =
    | Ident of { ident : Ident.t With_loc.t }
    | Constant of { value : int }
  [@@deriving equal, sexp_of]
end

module Assignment : sig
  type t =
    { comments : string list
    ; result : Ident.t With_loc.t
    ; operator_name : Operator_name.t With_loc.t
    ; arguments : Argument.t array
    }
  [@@deriving equal, sexp_of]
end

type t =
  { input : Ident.t With_loc.t array
  ; output : Ident.t With_loc.t array
  ; assignments : Assignment.t list
  ; head_comments : string list
  ; tail_comments : string list
  }
[@@deriving equal, sexp_of]
