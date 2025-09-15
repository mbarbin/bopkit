(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** A bopkit circuit holds a [Cds.t] along with information required to fire the
    computation of gates that are not entirely combinatorial, such as memories
    and external nodes.

    The type is exposed because it's really just a bare record of useful
    information, and used by bop2c and the bopkit simulator.

    The simulation logic is in [lib/bopkit_simulator]. *)

type t = private
  { path : Fpath.t
  ; main : string Loc.Txt.t
  ; rom_memories : Bit_matrix.t array
  ; external_blocks : Bopkit.Expanded_netlist.external_block array
  ; cds : Cds.t
  ; input_names : string array
  ; output_names : string array
  }

val create_exn
  :  path:Fpath.t
  -> main:string Loc.Txt.t
  -> rom_memories:Bit_matrix.t array
  -> external_blocks:Bopkit.Expanded_netlist.external_block array
  -> cds:Cds.t
  -> input_names:string array
  -> output_names:string array
  -> t
