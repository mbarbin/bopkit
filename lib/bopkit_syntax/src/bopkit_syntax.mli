open! Core

type t = Bopkit.Netlist.t

include Parsing_utils.S with type t := t
