(** This is an internal representation used as an intermediate step in the chain
    of transformations that leads to the final cds.

    This representation is quite close to the cds, and is the final step before
    actually creating the cds from it.

    It is composed of a raw list of gates, using named inputs and outputs, which
    are all signals. It always start with the input node, and finishes with the
    output node.

    This looks sort of like this:

    {v
       a, b, c = Input();
       d = And(a, b);
       e = Mux(b, c, d);
       ....
       ....
       j, k, ... = Gate(n, o, p, q, ...);
       ...
       ...
       = Output(x, y, z);
    v} *)

module Node : sig
  type t =
    { gate_kind : Bopkit_circuit.Gate_kind.t
    ; inputs : string array
    ; outputs : string array
    }
  [@@deriving sexp_of]
end

type t = Node.t array [@@deriving sexp_of]

(** Given this representation, compute the entire output_wires of the resulting
    cds, indexes by all variable names. *)
val output_wires : t -> Output_wires.t

val pp_debug : t -> _ Pp.t
