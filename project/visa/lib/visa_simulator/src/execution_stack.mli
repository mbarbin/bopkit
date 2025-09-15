(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

module Macro_frame : sig
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

val create : unit -> t
