(** A type used to manipulate the errors that occur when evaluating parameters,
    string_with_vars, etc. *)

type t =
  | Free_variable of
      { name : string
      ; candidates : string list
      }
  | Type_clash of { message : string }
  | Syntax_error of { in_ : string }
[@@deriving sexp_of]

val raise : t -> error_log:Error_log.t -> loc:Loc.t -> _
