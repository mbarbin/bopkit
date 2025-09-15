(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

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

(** An environment of expanded_blocks, indexed by their name. This allows for
    performing the lookups when encountering a call equal [Block { name }] in
    the body of another block. *)
type env = t Map.M(String).t
