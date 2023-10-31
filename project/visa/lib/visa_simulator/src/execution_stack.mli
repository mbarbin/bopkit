module Macro_frame : sig
  type t =
    { macro_name : Visa.Macro_name.t With_loc.t
    ; bindings :
        (Visa.Parameter_name.t * Visa.Assembly_instruction.Argument.t With_loc.t) list
    ; assembly_instructions : Visa.Assembly_instruction.t array
    ; mutable macro_code_pointer : int
    }
  [@@deriving sexp_of]
end

type t =
  { mutable code_pointer : int
  ; macro_frames : Macro_frame.t Stack.t
  }
[@@deriving sexp_of]

val create : unit -> t
