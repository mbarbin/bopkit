open! Core
open! Import

(** Translating a bopkit project into a standalone C file. The file can be
    compiled with [gcc], for example with optimization options like [-O3] for
    performant native simulation of a digital circuit.

    Bop2c hooks itself in the bopkit compiler pipeline just before the
    instantiation of the circuit, from the final CDS data structure obtained
    from the initial design. *)

val emit_c_code
  :  circuit:Bopkit_circuit.Circuit.t
  -> error_log:Error_log.t
  -> to_:Out_channel.t
  -> unit
