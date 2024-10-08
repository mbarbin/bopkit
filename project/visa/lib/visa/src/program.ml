module Constant_kind = struct
  type t =
    | Value of { value : int }
    | Address of { address : Address.t }
  [@@deriving equal, sexp_of]
end

module Top_level_construct = struct
  type t =
    | Newline
    | Comment of { text : string }
    | Constant_definition of
        { constant_name : Constant_name.t Loc.Txt.t
        ; constant_kind : Constant_kind.t
        }
    | Macro_definition of
        { macro_name : Macro_name.t Loc.Txt.t
        ; parameters : Parameter_name.t list
        ; body : Assembly_instruction.t list
        }
    | Label_introduction of { label : Label.t Loc.Txt.t }
    | Assembly_instruction of { assembly_instruction : Assembly_instruction.t }
  [@@deriving equal, sexp_of]
end

type t = Top_level_construct.t list [@@deriving equal, sexp_of]
