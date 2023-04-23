open! Core

module Statement : sig
  type t = private
    { labels : Visa.Label.t With_loc.t list
    ; assembly_instruction : Visa.Assembly_instruction.t
    }
  [@@deriving sexp_of]
end

type t = private
  { statements : Statement.t array
  ; labels_resolution : int Map.M(Visa.Label).t
  }
[@@deriving sexp_of]

val of_assembly_constructs
  :  assembly_constructs:Visa_assembler.Assembly_construct.t list
  -> t
