(** Interpreter for a bopkit process program. *)

(** Given an architecture parameter and an input program, interpret its
    evaluation - reading inputs from stdin and writing output to stdout in a
    loop until stdin is closed. *)
val run_program
  :  error_log:Error_log.t
  -> architecture:int
  -> program:Bopkit_process.Program.t
  -> unit Or_error.t
