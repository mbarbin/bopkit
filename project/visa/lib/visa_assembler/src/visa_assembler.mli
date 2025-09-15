(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

module Assembly_construct : sig
  (** After the environment is built, the assembler only keep these top level
      constructs from the original program. *)
  type t = private
    | Label_introduction of { label : Visa.Label.t Loc.Txt.t }
    | Assembly_instruction of { assembly_instruction : Visa.Assembly_instruction.t }
end

module Macro_definition : sig
  type t = private
    { macro_name : Visa.Macro_name.t Loc.Txt.t
    ; parameters : Visa.Parameter_name.t list
    ; body : Visa.Assembly_instruction.t list
    }
  [@@deriving sexp_of]
end

module Environment : sig
  (** All the definitions and labels of a program are gathered in an initial
      pass to build the environment. *)
  type t = private
    { constants : Visa.Program.Constant_kind.t Loc.Txt.t Map.M(Visa.Constant_name).t
    ; macros : Macro_definition.t Map.M(Visa.Macro_name).t
    ; labels : Visa.Label.t Loc.Txt.t Map.M(Visa.Label).t
    }
  [@@deriving sexp_of]
end

module Or_located_error : sig
  type 'a t = ('a, Loc.t * Error.t) Result.t

  val or_error : 'a t -> 'a Or_error.t
end

val build_environment
  :  program:Visa.Program.t
  -> Environment.t * Assembly_construct.t list

val lookup_argument
  :  environment:Environment.t
  -> bindings:
       (Visa.Parameter_name.t * Visa.Assembly_instruction.Argument.t Loc.Txt.t) list
  -> argument:Visa.Assembly_instruction.Argument.t Loc.Txt.t
  -> Visa.Assembly_instruction.Argument.t Loc.Txt.t Or_located_error.t

val build_instruction
  :  environment:Environment.t
  -> loc:Loc.t
  -> instruction_name:Visa.Instruction_name.t
  -> arguments:Visa.Assembly_instruction.Argument.t Loc.Txt.t list
  -> Visa.Label.t Visa.Instruction.t Or_located_error.t

val program_to_executable_with_labels
  :  program:Visa.Program.t
  -> Visa.Executable.With_labels.t

val program_to_executable : program:Visa.Program.t -> Visa.Executable.t
