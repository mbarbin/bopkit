(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Pretty printing  for bopkit files. *)

(** {1 Netlist constructs} *)

type t = Bopkit.Netlist.t

val pp : t -> _ Pp.t
val pp_parameter : Bopkit.Netlist.parameter -> _ Pp.t
val pp_variable : Bopkit.Netlist.variable -> _ Pp.t
val pp_block : Bopkit.Netlist.block -> _ Pp.t
