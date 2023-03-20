open! Core

(** Some bit encoding that are used throughout the project. *)

module Bit : sig
  type t = bool

  val of_char : Char.t -> t
  val to_char : t -> Char.t
end

module Bit_option : sig
  type t = bool option

  val of_char : Char.t -> t
  val to_char : t -> Char.t
end
