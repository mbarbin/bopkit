(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** All parameters of a project are aggregated, then sorted topologically and
    evaluated. We only keep the latest definition found in case of
    redefinitions. *)

val pass : Bopkit.Netlist.parameter list -> Bopkit.Parameters.t
