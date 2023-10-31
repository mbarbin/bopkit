type 'label t =
  (* $MDX part-begin=instructions *)
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
    (* $MDX part-end *)
[@@deriving equal, sexp_of]

let map t ~f =
  match t with
  | Nop -> Nop
  | Sleep -> Sleep
  | Add -> Add
  | And -> And
  | Swc -> Swc
  | Cmp -> Cmp
  | Not { register_name } -> Not { register_name }
  | Gof -> Gof
  | Jmp { label } -> Jmp { label = f label }
  | Jmn { label } -> Jmn { label = f label }
  | Jmz { label } -> Jmz { label = f label }
  | Store { register_name; address } -> Store { register_name; address }
  | Write { register_name; address } -> Write { register_name; address }
  | Load_address { address; register_name } -> Load_address { address; register_name }
  | Load_value { value; register_name } -> Load_value { value; register_name }
;;

let disassemble t ~disassemble_label =
  let instr instruction_name arguments =
    { Assembly_instruction.loc = Loc.dummy_pos
    ; operation_kind = Instruction { instruction_name }
    ; arguments = List.map arguments ~f:(fun a -> With_loc.with_dummy_pos a)
    }
  in
  match t with
  | Nop -> instr NOP []
  | Sleep -> instr SLEEP []
  | Add -> instr ADD []
  | And -> instr AND []
  | Swc -> instr SWC []
  | Cmp -> instr CMP []
  | Not { register_name } -> instr NOT [ Register { register_name } ]
  | Gof -> instr GOF []
  | Jmp { label } -> instr JMP [ Label { label = disassemble_label label } ]
  | Jmn { label } -> instr JMN [ Label { label = disassemble_label label } ]
  | Jmz { label } -> instr JMZ [ Label { label = disassemble_label label } ]
  | Store { register_name; address } ->
    instr STORE [ Register { register_name }; Address { address } ]
  | Write { register_name; address } ->
    instr WRITE [ Register { register_name }; Address { address } ]
  | Load_address { address; register_name } ->
    instr LOAD [ Address { address }; Register { register_name } ]
  | Load_value { value; register_name } ->
    instr LOAD [ Value { value }; Register { register_name } ]
;;

let to_string t ~label =
  Assembly_instruction.to_string (disassemble t ~disassemble_label:label)
;;
