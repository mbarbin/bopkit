module T = struct
  type argument =
    | Ident of { ident : Ident.t With_loc.t }
    | Constant of { value : int }

  and assignment =
    { comments : string list
    ; result : Ident.t With_loc.t
    ; operator_name : Operator_name.t With_loc.t
    ; arguments : argument array
    }

  and t =
    { input : Ident.t With_loc.t array
    ; output : Ident.t With_loc.t array
    ; assignments : assignment list
    ; head_comments : string list
    ; tail_comments : string list
    }
end

module Argument = struct
  type t = T.argument =
    | Ident of { ident : Ident.t With_loc.t }
    | Constant of { value : int }
  [@@deriving equal, sexp_of]
end

module Assignment = struct
  type t = T.assignment =
    { comments : string list
    ; result : Ident.t With_loc.t
    ; operator_name : Operator_name.t With_loc.t
    ; arguments : Argument.t array
    }
  [@@deriving equal, sexp_of]
end

type t = T.t =
  { input : Ident.t With_loc.t array
  ; output : Ident.t With_loc.t array
  ; assignments : Assignment.t list
  ; head_comments : string list
  ; tail_comments : string list
  }
[@@deriving equal, sexp_of]
