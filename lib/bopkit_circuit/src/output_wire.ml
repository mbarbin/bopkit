type t =
  { gate_index : int
  ; input_index : int
  }
[@@deriving compare, equal, hash, sexp_of]

module Short_sexp = struct
  type nonrec t = t [@@deriving compare, equal]

  let sexp_of_t { gate_index = g; input_index = i } =
    Sexp.Atom (Int.to_string g ^ ":" ^ Int.to_string i)
  ;;
end
