module T = struct
  type argument =
    | Ident of { ident : Ident.t Loc.Txt.t }
    | Constant of { value : int }

  and assignment =
    { comments : string list
    ; result : Ident.t Loc.Txt.t
    ; operator_name : Operator_name.t Loc.Txt.t
    ; arguments : argument array
    }

  and t =
    { input : Ident.t Loc.Txt.t array
    ; output : Ident.t Loc.Txt.t array
    ; assignments : assignment list
    ; head_comments : string list
    ; tail_comments : string list
    }
end

module Argument = struct
  type t = T.argument =
    | Ident of { ident : Ident.t Loc.Txt.t }
    | Constant of { value : int }
  [@@deriving equal, sexp_of]
end

module Assignment = struct
  type t = T.assignment =
    { comments : string list
    ; result : Ident.t Loc.Txt.t
    ; operator_name : Operator_name.t Loc.Txt.t
    ; arguments : Argument.t array
    }
  [@@deriving equal, sexp_of]
end

type t = T.t =
  { input : Ident.t Loc.Txt.t array
  ; output : Ident.t Loc.Txt.t array
  ; assignments : Assignment.t list
  ; head_comments : string list
  ; tail_comments : string list
  }
[@@deriving equal, sexp_of]
