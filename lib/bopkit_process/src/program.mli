(** A process program, as read and returned by the parser. *)

module Argument : sig
  type t =
    | Ident of { ident : Ident.t Loc.Txt.t }
    | Constant of { value : int }
  [@@deriving equal, sexp_of]
end

module Assignment : sig
  type t =
    { comments : string list
    ; result : Ident.t Loc.Txt.t
    ; operator_name : Operator_name.t Loc.Txt.t
    ; arguments : Argument.t array
    }
  [@@deriving equal, sexp_of]
end

type t =
  { input : Ident.t Loc.Txt.t array
  ; output : Ident.t Loc.Txt.t array
  ; assignments : Assignment.t list
  ; head_comments : string list
  ; tail_comments : string list
  }
[@@deriving equal, sexp_of]
