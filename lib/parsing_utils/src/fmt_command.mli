open! Core

(** Shared place to implement common [fmt] related commands, with the ability to
    control that the AST doesn't change, and reaches a fix point.

    Also contains the necessary utils to generate dune files that can extend the
    [dune fmt] rule to auto-format files with custom syntax. *)

module type T = sig
  type t [@@deriving equal, sexp_of]
end

module type T_pp = sig
  type t

  val pp : t -> unit Pp.t
end

val fmt_cmd
  :  (module T with type t = 'a)
  -> (module Parsing_utils.S with type t = 'a)
  -> (module T_pp with type t = 'a)
  -> Command.t

val pp_to_string : _ Pp.t -> string

(** Find all the files in the current directory that have one of the supplied
    extensions. *)
val find_files_in_cwd_by_extensions : extensions:string list -> string list

(** The pretty-printer may sometimes be used to perform some automatic
    refactoring on the files it formats. This is only possible when the
    environment variable BOPKIT_FORCE_FMT=true. *)
val bopkit_force_fmt : bool Lazy.t
