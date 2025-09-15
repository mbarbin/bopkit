(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** This is an intermediate structure as we map the AST from [Netlist.t] to
    [Expanded_netlist.t]. It's very close to a [Netlist.node] except that
    variables are decorated, and it is flat of control structures. *)

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
