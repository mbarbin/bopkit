(** All parameters of a project are aggregated, then sorted topologically and
    evaluated. We only keep the latest definition found in case of
    redefinitions. *)

val pass : Bopkit.Netlist.parameter list -> Bopkit.Parameters.t
