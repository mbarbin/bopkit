(** The interpreter does not execute the parsed code directly, but rather builds
    an intermediate code representation dedicated to the execution. This is a
    private abstraction used by the interpreter. *)

module Address : sig
  type t [@@deriving equal, sexp_of]
end

module Memory : sig
  (** The memory used by the interpreter is composed of all variables needed by
      the program, indexed by addresses. All variable occupy the same number
      of bits, given by the parameter [architecture]. Once a specific address
      has been fetched, its memory contents may be modified by side effect to
      the returned {!type:Bit_array.t}. *)

  type t [@@deriving sexp_of]

  val fetch : t -> address:Address.t -> Bit_array.t
end

module Instruction : sig
  type t = private
    | Input of { addresses : Address.t array }
    | Output of { addresses : Address.t array }
    | Operation of
        { operator : Operator.t
        ; operands : Address.t array (** [[| result; arg1; arg2; ... |]]. *)
        }
  [@@deriving sexp_of]
end

type t = private
  { architecture : int
  ; memory : Memory.t
  ; code : Instruction.t array
  }
[@@deriving sexp_of]

val of_program : architecture:int -> program:Bopkit_process.Program.t -> t
