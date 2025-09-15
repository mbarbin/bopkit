(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** [t] is the part of the internal state of the simulator that deals with
    values that are stored in ram as well as registers. It does not contain
    the code pointer. *)

type t [@@deriving sexp_of]

val create : unit -> t

(** Blit the memory with a contents read from a file at initialization time. *)
val load_initial_memory : t -> Bit_matrix.t -> unit

(** Get the output device from the machine. The output device is maintained up
    to date. The caller commits not to side-effect the returned structure, the
    behavior of the simulation is unspecified otherwise. *)
val output_device : t -> Output_device.t

(** [t] contains mutable values for each of the registers. This function allows
    access to the current contents. *)
val register_value : t -> register_name:Visa.Register_name.t -> int

(** [load t address register_name] fetches data from memory at given address and
    write it to the register whose name is supplied. *)
val load : t -> address:Visa.Address.t -> register_name:Visa.Register_name.t -> unit

(** As opposed to [load] which involves a [fetch] to memory, [load_value] sets
    the contents of the register whose name is supplied with the given
    immediate value. *)
val load_value : t -> value:int -> register_name:Visa.Register_name.t -> unit

(** [store t ~register_name ~address] is the opposite operation of [load] - it
    will write to memory at the given address the value currently contained in
    the register whose name is supplied. *)
val store : t -> register_name:Visa.Register_name.t -> address:Visa.Address.t -> unit

(** [write t ~register_name ~address] is like [store] but writes to the output
    device. It will write to the output device at the given address the value
    currently contained in the register whose name is supplied. *)
val write : t -> register_name:Visa.Register_name.t -> address:Visa.Address.t -> unit

(** {1 Operations on registers}

    Unless specified otherwise, when the operation is a binary operation
    involving both registers, the result is stored into [R1]. Example: [add]
    mutates [R1] with the result of [R0 + R1].

    Unary operations are available for both registers, as specified by the
    supplied register_name. Example: [not R0] negates the contents of register
    R0. *)

val add : t -> unit
val and_ : t -> unit
val switch : t -> unit

(** [R1 <- (R0 = R1)]. *)
val cmp : t -> unit

val not_ : t -> register_name:Visa.Register_name.t -> unit

(** The [overflow_flag] function returns a boolean value indicating whether the
    last arithmetic operation performed on the registers resulted in an
    overflow. Currently, the only operation that can cause an overflow is
    "add".

    Specifically, the [overflow_flag] is initially set to [false]. It is updated
    every time the [add] operation is performed: if the result of the addition
    strictly exceeds 255, the flag is set to [true], indicating an overflow;
    otherwise, it is reset to [false].

    This function provides a way to check the current state of the overflow
    flag. *)
val overflow_flag : t -> bool

(** [gof t] ("Get Overflow Flag") sets [R1] to the current value of the
    [overflow_flag] (1 for true and 0 for false). *)
val gof : t -> unit
