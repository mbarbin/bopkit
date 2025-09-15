(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type nested_inputs =
  | Variables of Bopkit.Expanded_netlist.variables
  | Nested_node of
      { loc : Loc.t
      ; call : Bopkit.Netlist.call
      ; inputs : nested_inputs list
      }

type t =
  { loc : Loc.t
  ; call : Bopkit.Expanded_netlist.call
  ; inputs : nested_inputs list
  ; outputs : Bopkit.Expanded_netlist.variables
  }
