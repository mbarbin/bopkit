type t

val default : t
val arg : t Command.Arg.t

(** {1 Getters} *)

val optimize_cds : t -> bool
val print_pass_output : t -> pass_name:Pass_name.t -> bool
val parameters_overrides : t -> Bopkit.Parameters.t
val main : t -> string option
