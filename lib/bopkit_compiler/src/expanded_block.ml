(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type call =
  | Block of { name : string }
  | Primitive of { gate_kind : Bopkit_circuit.Gate_kind.t }
[@@deriving sexp_of]

type node =
  { loc : Loc.t
  ; call : call
  ; inputs : string list
  ; outputs : string list
  }
[@@deriving sexp_of]

type t =
  { loc : Loc.t
  ; name : string
  ; local_variables : string list
  ; input_names : string array
  ; output_names : string array
  ; nodes : node list
  }
[@@deriving sexp_of]

type env = t Map.M(String).t
