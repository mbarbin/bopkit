module Code = Code
module Execution_stack = Execution_stack
module Memory = Memory

module Config : sig
  type t [@@deriving sexp_of]

  val arg : t Command.Arg.t
  val default : t

  val create
    :  ?sleep:bool
    -> ?stop_after_n_outputs:int
    -> ?initial_memory:Fpath.t
    -> unit
    -> t
end

(** It is possible to simulate the execution of a visa program, for example to
    debug an assembly code, or to quickly compute its resulting execution. *)

type t = private
  { environment : Visa_assembler.Environment.t
  ; code : Code.t
  ; execution_stack : Execution_stack.t
  ; memory : Memory.t
  ; config : Config.t
  }
[@@deriving sexp_of]

(** Create a new simulator from an assembly program. Having the assembly program
    is the most useful entry point when debugging, as the simulator will allow
    for following along with macro applications, etc.

    You may simulate the execution of an executable by disassembling it first
    (see {!val:Visa.Executable.disassemble}). *)
val create : config:Config.t -> program:Visa.Program.t -> t

module Step_result : sig
  type t =
    | Macro_call of { macro_name : Visa.Macro_name.t Loc.Txt.t }
    | Executed of
        { instruction : Visa.Label.t Visa.Instruction.t
        ; continue : bool
        }
  [@@deriving sexp_of]
end

val step : t -> Step_result.t Or_error.t
val run : t -> unit Or_error.t
val main : unit Command.t
