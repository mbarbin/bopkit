open! Core

module Assembly_construct : sig
  (** After the environment is built, the assembler only keep these top level
      constructs from the original program. *)
  type t = private
    | Label_introduction of { label : Visa.Label.t With_loc.t }
    | Assembly_instruction of { assembly_instruction : Visa.Assembly_instruction.t }
end

module Macro_definition : sig
  type t = private
    { macro_name : Visa.Macro_name.t With_loc.t
    ; parameters : Visa.Parameter_name.t list
    ; body : Visa.Assembly_instruction.t list
    }
  [@@deriving sexp_of]
end

module Environment : sig
  (** All the definitions and labels of a program are gathered in an initial
      pass to build the environment. *)
  type t = private
    { constants : Visa.Program.Constant_kind.t With_loc.t Map.M(Visa.Constant_name).t
    ; macros : Macro_definition.t Map.M(Visa.Macro_name).t
    ; labels : Visa.Label.t With_loc.t Map.M(Visa.Label).t
    }
  [@@deriving sexp_of]
end

module Or_located_error : sig
  type 'a t = ('a, Loc.t * Error.t) Result.t

  val or_error : 'a t -> 'a Or_error.t
end

val build_environment
  :  program:Visa.Program.t
  -> error_log:Error_log.t
  -> Environment.t * Assembly_construct.t list

val lookup_argument
  :  environment:Environment.t
  -> bindings:
       (Visa.Parameter_name.t * Visa.Assembly_instruction.Argument.t With_loc.t) list
  -> argument:Visa.Assembly_instruction.Argument.t With_loc.t
  -> Visa.Assembly_instruction.Argument.t With_loc.t Or_located_error.t

val build_instruction
  :  environment:Environment.t
  -> loc:Loc.t
  -> instruction_name:Visa.Instruction_name.t
  -> arguments:Visa.Assembly_instruction.Argument.t With_loc.t list
  -> Visa.Label.t Visa.Instruction.t Or_located_error.t

val program_to_executable_with_labels
  :  program:Visa.Program.t
  -> error_log:Error_log.t
  -> Visa.Executable.With_labels.t Or_error.t

val program_to_executable
  :  program:Visa.Program.t
  -> error_log:Error_log.t
  -> Visa.Executable.t Or_error.t
