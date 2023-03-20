open! Core

(** This is an internal representation used as an intermediate step in the chain
    of transformations that leads to the final cds.

    An [Expanded_block.t] is quite close to the blocks found in an
    [Expanded_netlist.t], except we've distinguished the primitives from other
    calls, and we've done more context verifications, such as arity checks.

    The environment formed by all [Expanded_block.t] indexed by their name is
    then used to create the [Expanded_nodes.t] structure. *)

type call =
  | Block of { name : string }
  | Primitive of { gate_kind : Bopkit_circuit.Gate_kind.t }
[@@deriving sexp_of]

(* CR mbarbin: Does it serve to keep the [loc] in here? *)
type node =
  { call : call
  ; inputs : string list
  ; outputs : string list
  }
[@@deriving sexp_of]

(* CR mbarbin: Remove [fichier], keep only [loc]. *)
(* CR mbarbin: arite* : maybe less redundant to use arrays and look at their lengths. *)
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

(** An environment of expanded_blocks, indexed by their name. This allows for
    performing the lookups when encountering a call equal [Block { name }] in
    the body of another block. *)
type env = t Map.M(String).t
