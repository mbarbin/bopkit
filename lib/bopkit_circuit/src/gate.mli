(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** The type that represents a gate, with the interconnection info.
    Output_wires: [output] and [output_wires] have the same length:
    [output_wires.(i)] are the output wires connected to [output.(i)], listing
    the gates this output is connected to. *)
type t =
  { gate_kind : Gate_kind.t
  ; input : Bit_array.Short_sexp.t
  ; output : Bit_array.Short_sexp.t
  ; output_wires : Output_wire.Short_sexp.t list array (** For each output. *)
  }
[@@deriving sexp_of]
