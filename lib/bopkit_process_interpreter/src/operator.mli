(** Process assumes a fixed architecture parameter N, that would be the length
    in bits of all the words that are manipulated at runtime.

    An operator is a function whose domain is a list of words, and whose result
    fits on 1 word. *)

type t [@@deriving sexp_of]

val operator_name : t -> Bopkit_process.Operator_name.t

(** The number of arguments expected by an operator. *)
val arity : t -> int

(** The implementation is such that by convention, the first element in the
    input array that an operator receives is the word where the result must be
    stored, by side effect.

    For example, calling: [and [| dst; arg1; arg2 |]] will result in [dst] to be
    filled with the result of the bitwise operation of [and(arg1, arg2)].
    Operators must commit not to side-effect their arguments - the result of a
    program is unspecified otherwise. *)
val compute : t -> operands:Bit_array.t array -> unit Or_error.t

module Env : sig
  type nonrec t = t Map.M(Bopkit_process.Operator_name).t
end

(** The operator available in programs, indexed by their name as they appear in
    the concrete syntax. *)
val primitives : Env.t Lazy.t
