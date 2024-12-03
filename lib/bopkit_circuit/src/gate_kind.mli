type t =
  | Input
  | Output
  | Id
  | Not
  | And
  | Or
  | Xor
  | Mux
  | Rom of
      { loc : Loc.t
      ; name : string
      ; index : int
      }
  | Ram of
      { loc : Loc.t
      ; name : string
      ; address_width : int
      ; data_width : int
      ; contents : Bit_matrix.t
      }
  | Reg of { initial_value : bool }
  | Regr of { index_of_regt : int }
  | Regt
  | Clock
  | Gnd
  | Vdd
  | External of
      { loc : Loc.t
      ; name : string
      ; method_name : string option
      ; arguments : string list
      ; protocol_prefix : string Core.Set_once.t
        (** The method name and the arguments are constant for a given gate,
          thus the simulator caches the prefix of the string that it will
          send to the external process. *)
      ; index : int Core.Set_once.t
        (** The index of the external gate in the process table is determined
          at runtime during the initialization of the simulation. *)
      }
[@@deriving sexp_of]

(** A pretty printer used for debugging. Does not need to (and doesn't) produce
    concrete syntax. *)
val pp_debug : t -> _ Pp.t

module Primitive : sig
  (** Starting from version [2.0], the syntax for primitives underwent a change:
      all lowercase identifiers were capitalized. For instance, "and" was
      replaced by "And". The pretty-printer now generates this new syntax for
      primitives. However, to ensure backward compatibility and facilitate a
      smooth transition, the parser still accepts the old lowercase
      identifiers as deprecated aliases. *)

  type nonrec t =
    { gate_kind : t
    ; input_width : int
    ; output_width : int
    ; keyword : string
    ; deprecated_aliases : string list
    }
  [@@deriving sexp_of]

  val all : t list Lazy.t
end
