(** This is the module responsible for displaying the state of the inputs and
    outputs of a circuit during the simulation. It's behavior can be tweaked via
    command line parameters passed in via the [Config.t] value supplied to
    [create]. *)

type t

val create : config:Config.t -> input_names:string array -> output_names:string array -> t

(** Certain output style requires to start the simulation with leading lines. To
    be executed once before the first cycle. *)
val init : t -> unit

(** Function called at each cycle to produce contents on [stdout], if required
    given the behavior requested in the config. *)
val output : t -> input:Bit_array.t -> output:Bit_array.t -> unit
