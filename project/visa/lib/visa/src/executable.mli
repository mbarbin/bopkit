(** In contrast to a {!type:Program.t} which may include higher level language
    constructs such as constants and macros definitions, an executable is a
    mere sequence of instructions. This is the expanded version of the program
    once the macros have been resolved.

    There are three flavors of executable that the assembler works with:

    - with instruction pointers {!type: t}: the instructions involving jumping
      to labels referring directly to raw address in the executable code.

    - with labels {!type:With_labels.t}: the instructions involving jumping to
      labels still use named labels as opposed to addresses in the code.

    - binary: the instruction have been translated from their human readable
      form into binary codes directly executable by the hardware machine
      implementing the microprocessor. *)

module With_labels : sig
  module Line : sig
    type t =
      { label_introduction : Label.t option
      ; instruction : Label.t Instruction.t
      }
    [@@deriving equal, sexp_of]
  end

  type t = Line.t array [@@deriving equal, sexp_of]

  val disassemble : t -> Program.t
end

module Instruction_pointer : sig
  (** An instruction pointer is the address of an instruction in the executable.
      That is the index in the executable array where this instruction is
      located. It's an integer. In this representation, there is no special
      introduction of labels anymore, any code location may serve as a label
      to jump to. *)
  type t [@@deriving equal, sexp_of]

  val to_int : t -> int
end

type t = Instruction_pointer.t Instruction.t array [@@deriving equal, sexp_of]

val resolve_labels : With_labels.t -> t
val disassemble : t -> Program.t

module Machine_code : sig
  type t = Machine_code.t [@@deriving equal, sexp_of]

  val disassemble : t -> filename:string -> error_log:Error_log.t -> Program.t
end

val to_machine_code : t -> Machine_code.t
