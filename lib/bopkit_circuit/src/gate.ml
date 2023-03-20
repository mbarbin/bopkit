open! Core

type t =
  { gate_kind : Gate_kind.t
  ; input : Bit_array.Short_sexp.t [@sexp.sexp_drop_if Array.is_empty]
  ; output : Bit_array.Short_sexp.t [@sexp.sexp_drop_if Array.is_empty]
  ; output_wires : Output_wire.Short_sexp.t list array [@sexp.sexp_drop_if Array.is_empty]
  }
[@@deriving sexp_of]
