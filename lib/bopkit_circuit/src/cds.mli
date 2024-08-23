(** According to ChatGPT :

    The acronym "CDS" stands for "Circuit Description System". It is a data
    structure used in digital circuit simulators to represent the logical gates
    and interconnections of a circuit.

    The concept of a Circuit Description System was first introduced by A.R.
    Newton and D.E. Thomas in their 1976 paper "Simulation of MOS Digital
    Systems using Switch-Level Timing Models". In this paper, they proposed a
    methodology for simulating digital circuits using switch-level timing
    models, and described the use of a Circuit Description System as a means of
    representing the circuit in a form that could be efficiently simulated.

    The CDS data structure typically consists of an array of gates, where each
    gate represents a logical function such as AND, OR, NOT, etc. The gates are
    connected by a set of wires, which represent the interconnections between
    gates. *)

type t = Gate.t array [@@deriving sexp_of]

(** Return [true] if there is a cycle in the cds, [false] otherwise. This is
    called prior to running [topological_sort]. *)
val detect_cycle : t -> bool

(** Perform a topological sort of the cds in place. *)
val topological_sort : t -> unit

(** Divide all [Reg _] gates into a pair of register transmitter and receiver
    ([Regr] and [Regt]), with the receiver pointing to the index of the
    transmitter in the cds. Returns a new cds in which the division has been
    done. *)
val split_registers : t -> t
