(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Translating a bopkit project into a standalone C file. The file can be
    compiled with [gcc], for example with optimization options like [-O3] for
    performant native simulation of a digital circuit.

    Bop2c hooks itself in the bopkit compiler pipeline just before the
    instantiation of the circuit, from the final CDS data structure obtained
    from the initial design. *)

val emit_c_code : circuit:Bopkit_circuit.Circuit.t -> to_:Out_channel.t -> unit
