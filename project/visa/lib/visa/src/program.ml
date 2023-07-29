open! Core

module Constant_kind = struct
  type t =
    | Value of { value : int }
    | Address of { address : Address.t }
  [@@deriving equal, sexp_of]
end

module Top_level_construct = struct
  (* CR mbarbin: Keep in the ast whether there're empty lines before
     or after a comment, and keep one line in that case in the [pp].
  *)
  (* CR mbarbin: Add the ability to have comments inside macros.
     Currently this yields a syntax error. *)
  (* CR mbarbin: Change the parser. Enforce the order of section.
     Currently it is confusing in that you may define a constant after
     it is used. *)
  type t =
    | Newline
    | Comment of { text : string }
    | Constant_definition of
        { constant_name : Constant_name.t With_loc.t
        ; constant_kind : Constant_kind.t
        }
    | Macro_definition of
        { macro_name : Macro_name.t With_loc.t
        ; parameters : Parameter_name.t list
        ; body : Assembly_instruction.t list
        }
    | Label_introduction of { label : Label.t With_loc.t }
    | Assembly_instruction of { assembly_instruction : Assembly_instruction.t }
  [@@deriving equal, sexp_of]
end

type t = Top_level_construct.t list [@@deriving equal, sexp_of]
