type t =
  | R0
  | R1
[@@deriving equal, sexp_of]

let to_string t =
  match sexp_of_t t with
  | List _ -> assert false
  | Atom s -> s
;;
