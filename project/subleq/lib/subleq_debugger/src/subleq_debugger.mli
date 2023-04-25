open! Core

(** The debugger allows you to run a subleq program step by step in a OCaml
    Graphics window. It will wait for the user to press 'enter' to make a
    step, and thus allows the user to follow along all the cycles of the
    computation. *)

type t

(** The initial memory contents is expected to have dimension [dimx:(2^N)] and
    [dimy:N] where N is the desired architecture for the subleq machine.
    [create_exn] will raise if the given memory doesn't have valid dimensions. *)
val create_exn : Bit_matrix.t -> t

(** The execution stops when the termination condition is met (pc=1), or run
    until the program is killed if this condition is never met. *)
val run : t -> unit
