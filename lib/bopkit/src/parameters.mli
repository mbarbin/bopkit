(** Bindings between parameter names and values. The type is a list, with the
    semantic that values added at the front of the list take precedence over
    other values present in the rest of the list. This allows for functional
    variable shadowing, by adding more elements to the front of an existing
    binding. *)

type t = Parameter.t list

val find : t -> parameter_name:string -> Parameter.Value.t option
val mem : t -> parameter_name:string -> bool
val keys : t -> string list

(** Defining command line parameters that can be used to supply overriding
    values for parameters contained in a circuit. *)
val overrides : t Command.Param.t
