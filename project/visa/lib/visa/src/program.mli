module Constant_kind : sig
  type t =
    | Value of { value : int }
    | Address of { address : Address.t }
  [@@deriving equal, sexp_of]
end

module Top_level_construct : sig
  (** Current Limitations:

      1. The Abstract Syntax Tree (AST) does not retain information about empty
      lines before or after a comment. Consequently, the pretty printer
      ([pp]) does not preserve these empty lines.

      2. Comments inside macros are not supported. Attempting to include a
      comment inside a macro will result in a syntax error.

      3. The parser does not enforce the order of sections. This can lead to
      confusion as it allows a constant to be defined after it is used. *)
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
