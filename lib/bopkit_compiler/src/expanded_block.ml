open! Core

type call =
  | Block of { name : string }
  | Primitive of { gate_kind : Bopkit_circuit.Gate_kind.t }
[@@deriving sexp_of]

type node =
  { call : call
  ; inputs : string list
  ; outputs : string list
  }
[@@deriving sexp_of]

type t =
  { loc : Loc.t
  ; fichier : string
  ; name : string
  ; arite_entree : int
  ; arite_sortie : int
  ; variables_locales : string list
  ; entrees_formelles : string list
  ; sorties_formelles : string list
  ; nodes : node list
  }
[@@deriving sexp_of]

type env = t Map.M(String).t
