(** In general the raw cds that is built from a netlist can be further
    optimized. The optimization process is a tradeoff between compile time and
    runtime performance.

    Here we do a simple pass to remove all the following gates from the cds:
    [Clock, Vdd, Gnd, Id].

    An older version also removed gates that have no side effects that do not
    have any outgoing wires, because their computation cannot have any impact on
    the simulation (external gates are kept, even with no output_wires, because
    they may contain side effects or graphical components). The older version
    hasn't been ported to the new version yet, so this is not done here.

    Also note that because this code hasn't been tested extensively, this code
    is not turned on by default. To be activated with [-optimize-cds true] in
    the command line. *)

val optimize : error_log:Error_log.t -> Bopkit_circuit.Cds.t -> Bopkit_circuit.Cds.t
