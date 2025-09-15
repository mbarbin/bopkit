(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

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
