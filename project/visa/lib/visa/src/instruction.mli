type 'label t =
  | Nop
  | Sleep
  | Add
  | And
  | Swc
  | Cmp
  | Not of { register_name : Register_name.t }
  | Gof
  | Jmp of { label : 'label }
  | Jmn of { label : 'label }
  | Jmz of { label : 'label }
  | Store of
      { register_name : Register_name.t
      ; address : Address.t
      }
  | Write of
      { register_name : Register_name.t
      ; address : Address.t
      }
  | Load_address of
      { address : Address.t
      ; register_name : Register_name.t
      }
  | Load_value of
      { value : int
      ; register_name : Register_name.t
      }
[@@deriving equal, sexp_of]

val map : 'a t -> f:('a -> 'b) -> 'b t
val to_string : 'a t -> label:('a -> Label.t) -> string
val disassemble : 'a t -> disassemble_label:('a -> Label.t) -> Assembly_instruction.t
