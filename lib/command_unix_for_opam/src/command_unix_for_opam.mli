(** This util library is meant to improve compatibility of core commands with the
    opam distribution process. *)

(** [run cmd] is the same as [Command_unix.run cmd] but adds extra parameters so
    that invocations of the command with [-version] outputs the package
    version. *)
val run : Command.t -> unit
