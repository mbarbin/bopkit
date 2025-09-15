(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Visa_dsl is an OCaml API to create visa-assembly program. Another way to
    describe it is that it is an embedded DSL for visa, where the host language
    is OCaml. *)

module Session : sig
  type t
end

val program : (Session.t -> unit) -> Visa.Program.t

module O : sig
  (** {1 Typed expressions} *)

  type value

  val value : int -> value

  type address

  val address : int -> address

  type output

  val output : int -> output

  type label

  val label : string -> label

  type register = Visa.Register_name.t

  (** {1 Constant definitions} *)

  val define_address : Session.t -> string -> int -> address
  val define_value : Session.t -> string -> int -> value

  (** {1 Macro definitions} *)

  type 'a macro

  module Parameters : sig
    type _ t =
      | Address : string -> address t
      | Output : string -> output t
      | Label : string -> label t
      | Value : string -> value t
      | T2 : ('a t * 'b t) -> ('a * 'b) t
      | T3 : ('a t * 'b t * 'c t) -> ('a * 'b * 'c) t
  end

  val macro
    :  name:string
    -> parameters:'a Parameters.t
    -> f:(Session.t -> 'a -> unit)
    -> 'a macro

  val define_macro : Session.t -> _ macro -> unit
  val call_macro : Session.t -> 'a macro -> 'a -> unit

  (** {1 Label introductions} *)

  val add_label : Session.t -> label -> unit
  val add_new_label : Session.t -> string -> label

  (** {1 Assembly instructions} *)

  val nop : Session.t -> unit
  val sleep : Session.t -> unit
  val add : Session.t -> unit
  val and_ : Session.t -> unit
  val swc : Session.t -> unit
  val cmp : Session.t -> unit
  val not_ : Session.t -> register -> unit
  val gof : Session.t -> unit
  val jmp : Session.t -> label -> unit
  val jmn : Session.t -> label -> unit
  val jmz : Session.t -> label -> unit
  val store : Session.t -> register -> address -> unit
  val write : Session.t -> register -> output -> unit
  val load_address : Session.t -> address -> register -> unit
  val load_value : Session.t -> value -> register -> unit
end

(** {1 Advanced uses} *)

module Advanced : sig
  type t

  val create : unit -> t
  val session : t -> Session.t
  val program : t -> Visa.Program.t
end
