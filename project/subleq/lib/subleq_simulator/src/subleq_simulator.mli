(** The subleq simulator allows you to compute the result of the subleq
    computation from a starting RAM image. If the process loops, the simulator
    detects it and aborts the computation, otherwise you can print the RAM
    image resulting from its successful computation. *)

type t

(** Create a new simulator with the desired architecture. The architecture is
    the width of the words contains in the RAM. The same simulator may be used
    on several programs, however if you want to change the architecture you
    need to create a new [t]. *)
val create : architecture:int -> t

(** Load the contents of the given memory into [t] to start the execution of a
    new program. The memory dimensions are expected to be [dimx:2^N] and
    [dimy:N] where N is the set architecture. This will reset the program
    counter to 0. *)
val reset_exn : t -> Bit_matrix.t -> unit

module Run_result : sig
  type t =
    | Success
    | Program_does_not_terminate
  [@@deriving equal, sexp_of]
end

(** Launch the simulator, compute the subleq RAM image or detect a
    cycle and abort. *)
val run : t -> Run_result.t

(** After running the program you may be interested in getting back
    the RAM image resulting from the computation. If [run t] returned
    [Program_does_not_terminate] the contents of the memory is not
    specified, and we make not guarantee about its meaning or
    stability. *)
val print_memory : t -> out_channel:Out_channel.t -> unit
