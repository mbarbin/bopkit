open! Core

(** A code formatter for visa programs, e.g. to be used by [dune fmt]. *)

type t = Visa.Program.t

val pp : t -> _ Pp.t
