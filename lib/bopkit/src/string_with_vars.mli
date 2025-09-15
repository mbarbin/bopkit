(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** String with variables %\{...\} in it. This allows commands to depend on
    parameters, etc. *)

type t [@@deriving equal, sexp_of]

val eval : t -> parameters:Parameters.t -> string Or_eval_error.t
val vars : t -> string Appendable_list.t
val parse : string -> t Or_eval_error.t

module Parts : sig
  (** Show the parts of [t]. *)
  type nonrec t = t [@@deriving sexp_of]
end

module Syntax : sig
  (** We are in the process of transitioning from $(...) to %\{...\}. Meanwhile
      both syntax are accepted, and the printer can decide which to use. *)
  type t =
    | Dollar
    | Percent
end

val to_string : ?syntax:Syntax.t -> t -> string

module Private : sig
  module Part : sig
    type t =
      | Text of string
      | Var of string
    [@@deriving equal, sexp_of]
  end

  val to_parts : t -> Part.t list
end
