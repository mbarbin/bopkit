module Macro_frame : sig
  include module type of Visa_simulator.Execution_stack.Macro_frame

  val render_lines_for_debugging : t -> string list
end

include
  module type of Visa_simulator.Execution_stack with module Macro_frame := Macro_frame

(** The code is rendered in a way that makes it friendly to look at in the
    debugger window. This does not contain the [labels_resolution]. *)
val render_lines_for_debugging : t -> string list
