open! Core
open! Import

(** All parameters of a project are aggregated, then sorted topologically and
    evaluated. We only keep the latest definition found in case of
    redefinitions. *)

val pass : Bopkit.Netlist.parameter list -> error_log:Error_log.t -> Bopkit.Parameters.t
