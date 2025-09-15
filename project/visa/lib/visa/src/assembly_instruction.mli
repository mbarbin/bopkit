(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

module Operation_kind : sig
  type t =
    | Macro_call of { macro_name : Macro_name.t }
    | Instruction of { instruction_name : Instruction_name.t }
  [@@deriving equal, sexp_of]
end

module Argument : sig
  type t =
    | Value of { value : int }
    | Address of { address : Address.t }
    | Constant of { constant_name : Constant_name.t }
    | Label of { label : Label.t }
    | Register of { register_name : Register_name.t }
    | Parameter of { parameter_name : Parameter_name.t }
  [@@deriving equal, sexp_of]

  val to_string : t -> string
end

type t =
  { loc : Loc.t
  ; operation_kind : Operation_kind.t
  ; arguments : Argument.t Loc.Txt.t list
  }
[@@deriving equal, sexp_of]

val to_string : t -> string
