open! Core

type t

val default : t
val param : t Command.Param.t

(** {1 Getters} *)

val optimise_cds : t -> bool
val print_pass_output : t -> pass_name:Pass_name.t -> bool
