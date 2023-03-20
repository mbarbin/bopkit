open! Core

(** Primitives are the building block of circuits. During the various
    transformations performed as we build the circuit, we refer to an
    environment of primitives indexed by their name to resolve the calls, and
    perform arity checks. *)

type t =
  { gate_kind : Bopkit_circuit.Gate_kind.t
  ; input_width : int
  ; output_width : int
  }
[@@deriving sexp_of]

(** An environment of primitives, indexed by their name in the concrete syntax
    (example "and", "or", etc). Note that definition memories add new
    primitives to such an environment, so it can also contain them depending
    where we are in the compilation pipeline. *)
type env = t Map.M(String).t

val initial_env : env Lazy.t
