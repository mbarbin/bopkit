module Session = struct
  type t = { program : Visa.Program.Top_level_construct.t Queue.t }

  let create () = { program = Queue.create () }
end

module Advanced = struct
  type t = Session.t

  let create = Session.create
  let session t = t
  let program (t : t) : Visa.Program.t = Queue.to_list t.program
end

let program f =
  let t = Advanced.create () in
  f (Advanced.session t);
  Advanced.program t
;;

module O = struct
  type t = Session.t
  type value = Visa.Assembly_instruction.Argument.t

  let value i : value = Value { value = i }

  type address = Visa.Assembly_instruction.Argument.t

  let address i : address = Address { address = Visa.Address.of_int i }

  type output = address

  let output = address

  type label = Visa.Assembly_instruction.Argument.t

  let label name : label = Label { label = Visa.Label.of_string name }

  type register = Visa.Register_name.t

  let define_address (t : t) name address : address =
    let address = Visa.Address.of_int address in
    let constant_name = Visa.Constant_name.of_string name in
    Queue.enqueue
      t.program
      (Constant_definition
         { constant_name = Loc.Txt.no_loc constant_name
         ; constant_kind = Address { address }
         });
    Constant { constant_name }
  ;;

  let define_value (t : t) name value : value =
    let constant_name = Visa.Constant_name.of_string name in
    Queue.enqueue
      t.program
      (Constant_definition
         { constant_name = Loc.Txt.no_loc constant_name; constant_kind = Value { value } });
    Constant { constant_name }
  ;;

  module Parameters = struct
    type _ t =
      | Address : string -> address t
      | Output : string -> output t
      | Label : string -> label t
      | Value : string -> value t
      | T2 : ('a t * 'b t) -> ('a * 'b) t
      | T3 : ('a t * 'b t * 'c t) -> ('a * 'b * 'c) t

    let parameter_name name = Visa.Parameter_name.of_string name

    let argument name =
      Visa.Assembly_instruction.Argument.Parameter
        { parameter_name = parameter_name name }
    ;;

    let rec to_list : type a. a t -> Visa.Parameter_name.t list = function
      | Address name -> [ parameter_name name ]
      | Output name -> [ parameter_name name ]
      | Label name -> [ parameter_name name ]
      | Value name -> [ parameter_name name ]
      | T2 (a, b) -> to_list a @ to_list b
      | T3 (a, b, c) -> to_list a @ to_list b @ to_list c
    ;;

    let rec input : type a. a t -> a = function
      | Address name -> argument name
      | Output name -> argument name
      | Label name -> argument name
      | Value name -> argument name
      | T2 (a, b) -> input a, input b
      | T3 (a, b, c) -> input a, input b, input c
    ;;

    let rec arguments : type a. a t -> a -> Visa.Assembly_instruction.Argument.t list =
      fun t a ->
      match t, a with
      | Address _, address -> [ address ]
      | Output _, output -> [ output ]
      | Label _, label -> [ label ]
      | Value _, value -> [ value ]
      | T2 (ta, tb), (a, b) -> arguments ta a @ arguments tb b
      | T3 (ta, tb, tc), (a, b, c) -> arguments ta a @ arguments tb b @ arguments tc c
    ;;
  end

  type 'a macro =
    { macro_name : Visa.Macro_name.t
    ; parameters : 'a Parameters.t
    ; f : Session.t -> 'a -> unit
    }

  let macro ~name ~parameters ~f =
    { macro_name = Visa.Macro_name.of_string name; parameters; f }
  ;;

  let define_macro (t : t) macro =
    let session = Session.create () in
    let body =
      macro.f session (Parameters.input macro.parameters);
      Queue.to_list session.program
      |> List.map ~f:(fun top_level_construct ->
        match (top_level_construct : Visa.Program.Top_level_construct.t) with
        | ( Newline
          | Comment _
          | Constant_definition _
          | Macro_definition _
          | Label_introduction _ ) as construct ->
          raise_s
            [%sexp
              "Invalid visa construct inside macro"
            , [%here]
            , (construct : Visa.Program.Top_level_construct.t)]
        | Assembly_instruction { assembly_instruction = i } -> i)
    in
    Queue.enqueue
      t.program
      (Macro_definition
         { macro_name = Loc.Txt.no_loc macro.macro_name
         ; parameters = Parameters.to_list macro.parameters
         ; body
         })
  ;;

  let call_macro (t : t) macro input =
    Queue.enqueue
      t.program
      (Assembly_instruction
         { assembly_instruction =
             { loc = Loc.none
             ; operation_kind = Macro_call { macro_name = macro.macro_name }
             ; arguments =
                 Parameters.arguments macro.parameters input |> List.map ~f:Loc.Txt.no_loc
             }
         })
  ;;

  let add_label (t : t) label =
    match (label : label) with
    | Label { label } ->
      Queue.enqueue t.program (Label_introduction { label = Loc.Txt.no_loc label })
    | _ ->
      raise_s
        [%sexp
          "Invalid label value", [%here], { label : Visa.Assembly_instruction.Argument.t }]
  ;;

  let add_new_label (t : t) name =
    let label = label name in
    add_label t label;
    label
  ;;

  let assembly_instruction (t : t) ~instruction_name ~arguments =
    Queue.enqueue
      t.program
      (Assembly_instruction
         { assembly_instruction =
             { loc = Loc.none
             ; operation_kind = Instruction { instruction_name }
             ; arguments = List.map arguments ~f:(fun a -> Loc.Txt.no_loc a)
             }
         })
  ;;

  let nop t = assembly_instruction t ~instruction_name:NOP ~arguments:[]
  let sleep t = assembly_instruction t ~instruction_name:SLEEP ~arguments:[]
  let add t = assembly_instruction t ~instruction_name:ADD ~arguments:[]
  let and_ t = assembly_instruction t ~instruction_name:AND ~arguments:[]
  let swc t = assembly_instruction t ~instruction_name:SWC ~arguments:[]
  let cmp t = assembly_instruction t ~instruction_name:CMP ~arguments:[]

  let not_ t register_name =
    assembly_instruction t ~instruction_name:NOT ~arguments:[ Register { register_name } ]
  ;;

  let gof t = assembly_instruction t ~instruction_name:GOF ~arguments:[]
  let jmp t label = assembly_instruction t ~instruction_name:JMP ~arguments:[ label ]
  let jmn t label = assembly_instruction t ~instruction_name:JMN ~arguments:[ label ]
  let jmz t label = assembly_instruction t ~instruction_name:JMZ ~arguments:[ label ]

  let store t register_name address =
    assembly_instruction
      t
      ~instruction_name:STORE
      ~arguments:[ Register { register_name }; address ]
  ;;

  let write t register_name output =
    assembly_instruction
      t
      ~instruction_name:WRITE
      ~arguments:[ Register { register_name }; output ]
  ;;

  let load_address t address register_name =
    assembly_instruction
      t
      ~instruction_name:LOAD
      ~arguments:[ address; Register { register_name } ]
  ;;

  let load_value t value register_name =
    assembly_instruction
      t
      ~instruction_name:LOAD
      ~arguments:[ value; Register { register_name } ]
  ;;
end
