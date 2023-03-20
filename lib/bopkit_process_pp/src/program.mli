open! Core

(** A code formatter for programs, e.g. to be used by [dune fmt]. *)

type t = Bopkit_process.Program.t

val pp : t -> _ Pp.t
