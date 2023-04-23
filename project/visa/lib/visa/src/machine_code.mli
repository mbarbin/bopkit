open! Core

module Byte : sig
  (** Visa's machine instructions may be encoded on 1 or 2 byte. *)

  (** 8 bits. *)
  type t = Bit_array.t [@@deriving equal, sexp_of]

  val of_int_exn : int -> t
  val to_string : t -> string
end

type t = Byte.t array [@@deriving equal, sexp_of]

val of_text_file_exn : filename:string -> error_log:Error_log.t -> t

(** Compile down instructions into a binary encoding that can be read by the
    microprocessor. *)
val of_instructions : int Instruction.t array -> t

(** Disassemble the binary code to produce back an original sequence of
    instructions. *)
val to_instructions
  :  t
  -> filename:string
  -> error_log:Error_log.t
  -> int Instruction.t array

module For_testing : sig
  module Operation : sig
    type t [@@deriving equal, enumerate, sexp_of]

    val to_byte : t -> Byte.t
    val of_byte : Byte.t -> t option
    val op_code : t -> int
  end
end
