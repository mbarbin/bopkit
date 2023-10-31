module T = struct
  type 'a t =
    { loc : Loc.t
    ; symbol : 'a
    }
  [@@deriving sexp_of]
end

type 'a t = 'a T.t =
  { loc : Loc.t
  ; symbol : 'a
  }
[@@deriving equal, fields]

let sexp_of_t sexp_of_a t =
  if !Loc.include_sexp_of_positions then T.sexp_of_t sexp_of_a t else sexp_of_a t.symbol
;;

let create loc symbol = { loc = Loc.create loc; symbol }
let to_string t = Loc.to_string t.loc
let map t ~f = { t with symbol = f t.symbol }
let with_dummy_pos symbol = { loc = Loc.dummy_pos; symbol }
