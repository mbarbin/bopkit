type t = int [@@deriving equal, sexp_of]

let of_int t = t
let to_int t = t
let to_string t = Int.to_string t
