include module type of Visa_simulator.Code

(** The code is rendered in a way that makes it friendly to look at in the
    debugger window. This does not contain the [labels_resolution]. *)
val render_lines_for_debugging : t -> string list
