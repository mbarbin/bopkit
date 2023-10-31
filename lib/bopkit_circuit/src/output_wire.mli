(** Each of the output bit of a gate can be connected to the input of other
    gates. Since the cds is sorted topologically, such input gate necessarily
    appears after the output gate in the cds.

    An output wire designates exactly which input of which gate the output bit is
    connected to. Note that an output may be connected to several inputs, so each
    output may have several output wires. An the other hand, an input may be
    connected to at most one single output wire.

    The [gate_index] is the array index of the input gate this output wire is
    connected to in the cds.

    The [input_index] is the array index of the actual input bit of that gate the
    wire is connected to. *)
type t =
  { gate_index : int
  ; input_index : int
  }
[@@deriving compare, equal, hash, sexp_of]

module Short_sexp : sig
  (** Produces Atom "GATE_INDEX:INPUT_INDEX". This makes cds sexp more human
      readable. *)
  type nonrec t = t [@@deriving compare, equal, sexp_of]
end
