open! Or_error.Let_syntax

module Address = struct
  type t = { memory_index : int } [@@deriving equal, sexp_of]
end

module Memory = struct
  type t = Bit_array.t array [@@deriving sexp_of]

  let fetch (t : t) ~address:{ Address.memory_index = i } = t.(i)
end

module Instruction = struct
  type t =
    | Input of { addresses : Address.t array }
    | Output of { addresses : Address.t array }
    | Operation of
        { operator : Operator.t
        ; operands : Address.t array
        }
  [@@deriving sexp_of]
end

type t =
  { architecture : int
  ; memory : Memory.t
  ; code : Instruction.t array
  }
[@@deriving sexp_of]

let unknown_operator_error
  ~error_log
  ~(operator_name : Bopkit_process.Operator_name.t With_loc.t)
  =
  Error_log.error
    error_log
    ~loc:operator_name.loc
    [ Pp.textf
        "operator '%s' is not defined"
        (Bopkit_process.Operator_name.to_string operator_name.symbol)
    ]
;;

let operator_arity_error
  ~error_log
  ~(operator_name : Bopkit_process.Operator_name.t With_loc.t)
  ~arity
  ~number_of_arguments
  =
  Error_log.error
    error_log
    ~loc:operator_name.loc
    [ Pp.textf
        "Operator '%s' has arity %d but is applied to %d argument%s"
        (Bopkit_process.Operator_name.to_string operator_name.symbol)
        arity
        number_of_arguments
        (if number_of_arguments > 1 then "s" else "")
    ]
;;

let of_program ~error_log ~architecture ~(program : Bopkit_process.Program.t) =
  let next_memory_index =
    let index = ref (-1) in
    fun () ->
      Int.incr index;
      !index
  in
  let addresses : Address.t Hashtbl.M(Bopkit_process.Ident).t =
    Hashtbl.create (module Bopkit_process.Ident)
  in
  let memory : Bit_array.t Hashtbl.M(Int).t = Hashtbl.create (module Int) in
  let var_map ~is_assigned argument =
    match (argument : Bopkit_process.Program.Argument.t) with
    | Constant { value = constant } ->
      let value = Array.create ~len:architecture false in
      Bit_array.blit_int ~dst:value ~src:constant;
      let memory_index = next_memory_index () in
      Hashtbl.set memory ~key:memory_index ~data:value;
      { Address.memory_index }
    | Ident { ident } ->
      (match Hashtbl.find addresses ident.symbol with
       | Some v -> v
       | None ->
         if not is_assigned
         then
           Error_log.error
             error_log
             ~loc:ident.loc
             [ Pp.textf
                 "Variable '%s' is read before assignment"
                 (Bopkit_process.Ident.to_string ident.symbol)
             ];
         let memory_index = next_memory_index () in
         let address = { Address.memory_index } in
         let value = Array.create ~len:architecture false in
         Hashtbl.set addresses ~key:ident.symbol ~data:address;
         Hashtbl.set memory ~key:memory_index ~data:value;
         address)
  in
  let code : Instruction.t Queue.t = Queue.create () in
  Queue.enqueue
    code
    (Input
       { addresses =
           Array.map program.input ~f:(fun ident ->
             var_map ~is_assigned:true (Ident { ident }))
       });
  List.iter
    program.assignments
    ~f:(fun { comments = _; result; operator_name; arguments } ->
      let operands =
        Array.concat
          [ [| Bopkit_process.Program.Argument.Ident { ident = result } |]; arguments ]
        |> Array.mapi ~f:(fun i operand -> var_map ~is_assigned:(i = 0) operand)
      in
      match Map.find (force Operator.primitives) operator_name.symbol with
      | None -> unknown_operator_error ~error_log ~operator_name
      | Some operator ->
        let arity = Operator.arity operator in
        let number_of_arguments = Array.length arguments in
        if arity <> number_of_arguments
        then operator_arity_error ~error_log ~operator_name ~arity ~number_of_arguments
        else Queue.enqueue code (Operation { operator; operands }));
  Queue.enqueue
    code
    (Output
       { addresses =
           Array.map program.output ~f:(fun ident ->
             var_map ~is_assigned:false (Ident { ident }))
       });
  let code = Queue.to_array code in
  let num_addresses = next_memory_index () in
  let memory =
    Array.init num_addresses ~f:(fun i ->
      Hashtbl.find memory i |> Option.value_exn ~here:[%here])
  in
  let%bind () = Error_log.checkpoint error_log in
  return { architecture; memory; code }
;;
