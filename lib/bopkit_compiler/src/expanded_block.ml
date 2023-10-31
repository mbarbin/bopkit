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
  ; local_variables : string list
  ; input_names : string array
  ; output_names : string array
  ; nodes : node list
  }
[@@deriving sexp_of]

type env = t Map.M(String).t
