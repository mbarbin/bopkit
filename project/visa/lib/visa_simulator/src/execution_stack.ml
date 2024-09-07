module Macro_frame = struct
  type t =
    { macro_name : Visa.Macro_name.t Loc.Txt.t
    ; bindings :
        (Visa.Parameter_name.t * Visa.Assembly_instruction.Argument.t Loc.Txt.t) list
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

let create () = { code_pointer = 0; macro_frames = Stack.create () }
