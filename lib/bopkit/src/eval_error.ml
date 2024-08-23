type t =
  | Free_variable of
      { name : string
      ; candidates : string list
      }
  | Type_clash of { message : string }
  | Syntax_error of { in_ : string }
[@@deriving sexp_of]

let raise t ~loc =
  match t with
  | Syntax_error { in_ = m } ->
    Err.raise ~loc [ Pp.textf "In: '%s'" m; Pp.text "Syntax error." ]
  | Free_variable { name; candidates } ->
    Err.raise
      ~loc
      [ Pp.textf "Unbound variable '%s'." name ]
      ~hints:(Err.did_you_mean name ~candidates)
  | Type_clash { message = m } -> Err.raise ~loc [ Pp.text m ]
;;
