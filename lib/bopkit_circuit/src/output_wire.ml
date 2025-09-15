(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

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
