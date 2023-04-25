open! Core

(** This module allows you to generate subleq programs. We make use of this
    program to generate random inputs for our regression tests. *)

type t

(** The programs and their expected computation will be saved on disk using
    filenames computed from [generated_files_prefix], onto which we'll add the
    index number and the extensions ".input" and ".output". *)
val create
  :  architecture:int
  -> with_cycle:bool
  -> number_of_programs:int
  -> generated_files_prefix:string
  -> t

val generate_all : t -> unit
