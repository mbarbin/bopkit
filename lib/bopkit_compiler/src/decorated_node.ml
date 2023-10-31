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
