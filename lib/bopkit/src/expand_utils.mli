(** Some utils while expanded elements of a [Netlist.t] into elements of an
    [Expanded_netlist.t]. *)

val interval_of_index : Expanded_netlist.index -> Interval.t
val expand_indexes : Expanded_netlist.index list -> f:(int -> string) -> string list

val eval_index
  :  Netlist.index
  -> loc:Loc.t
  -> error_log:Error_log.t
  -> parameters:Parameters.t
  -> Expanded_netlist.index

val eval_variable
  :  Netlist.variable
  -> error_log:Error_log.t
  -> parameters:Parameters.t
  -> Expanded_netlist.variable

val expand_variable
  :  Netlist.variable
  -> error_log:Error_log.t
  -> parameters:Parameters.t
  -> string list

val expand_const_variable : Expanded_netlist.variable -> string list
