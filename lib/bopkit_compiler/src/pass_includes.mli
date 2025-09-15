(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Create the standalone netlist from all of the project's files, simply by
    concatenating them all. Topological ordering is done separately later. *)

val pass : path:Fpath.t -> Standalone_netlist.t
