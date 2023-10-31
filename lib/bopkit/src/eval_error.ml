type t =
  | Free_variable of
      { name : string
      ; candidates : string list
      }
  | Type_clash of { message : string }
  | Syntax_error of { in_ : string }
[@@deriving sexp_of]

let raise t ~error_log ~loc =
  match t with
  | Syntax_error { in_ = m } ->
    Error_log.raise error_log ~loc [ Pp.textf "In: '%s'" m; Pp.text "Syntax error." ]
  | Free_variable { name; candidates } ->
    Error_log.raise
      error_log
      ~loc
      [ Pp.textf "Unbound variable '%s'." name ]
      ~hints:(Error_log.did_you_mean name ~candidates)
  | Type_clash { message = m } -> Error_log.raise error_log ~loc [ Pp.text m ]
;;
