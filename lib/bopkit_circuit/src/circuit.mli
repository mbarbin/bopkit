open! Core

(** A bopkit circuit holds a [Cds.t] along with information required to fire the
    computation of gates that are not entirely combinatorial, such as memories
    and external nodes.

    The type is exposed because it's really just a bare record of useful
    information, and used by bop2c and the bopkit simulator.

    The simulation logic is in [lib/bopkit_simulator]. *)

type t = private
  { filename : string
  ; main : string
  ; rom_memories : Bit_matrix.t array
  ; external_blocks : Bopkit.Expanded_netlist.external_block array
  ; cds : Cds.t
  ; input_names : string array
  ; output_names : string array
  }

val create_exn
  :  filename:string
  -> main:string
  -> rom_memories:Bit_matrix.t array
  -> external_blocks:Bopkit.Expanded_netlist.external_block array
  -> cds:Cds.t
  -> input_names:string array
  -> output_names:string array
  -> t
