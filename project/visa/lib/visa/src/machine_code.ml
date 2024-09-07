module Byte = struct
  type t = Bit_array.t [@@deriving equal]

  let sexp_of_t (t : t) = [%sexp (t : Bit_array.Short_sexp.t)]
  let max_value = Int.pow 2 8

  let of_int_exn n =
    if n < 0 || n >= max_value
    then raise_s [%sexp Overflow, [%here], { max_value : int; n : int }]
    else (
      let t = Array.create ~len:8 false in
      Bit_array.blit_int ~src:n ~dst:t;
      t)
  ;;

  let to_string t = Bit_array.to_string t
end

module Operation = struct
  type t =
    | Nop
    | Sleep
    | Add
    | And
    | Swc
    | Cmp
    | Not_R0
    | Not_R1
    | Gof
    | Jmp
    | Jmn
    | Jmz
    | Store_R0
    | Store_R1
    | Load_R0
    | Load_R1
    | Load_value_R0
    | Load_value_R1
  [@@deriving equal, enumerate, sexp_of]

  let to_string t = Sexp.to_string_hum [%sexp (t : t)]

  let to_int t =
    match t with
    | Nop -> 0
    | Sleep -> 1
    | Add -> 2
    | And -> 3
    | Swc -> 4
    | Cmp -> 5
    | Not_R0 -> 6
    | Not_R1 -> 6 lor 16
    | Gof -> 7
    | Jmp -> 8
    | Jmn -> 9
    | Jmz -> 10
    | Store_R0 -> 11
    | Store_R1 -> 11 lor 16
    | Load_R0 -> 12 lor 32
    | Load_R1 -> 12 lor 32 lor 16
    | Load_value_R0 -> 12
    | Load_value_R1 -> 12 lor 16
  ;;

  let to_byte t = Byte.of_int_exn (to_int t)

  let codes =
    lazy
      (let table = Hashtbl.create (module Int) in
       List.iter all ~f:(fun t -> Hashtbl.set table ~key:(to_int t) ~data:t);
       table)
  ;;

  let of_byte (byte : Byte.t) =
    let code = Bit_array.to_int byte in
    Hashtbl.find (force codes) code
  ;;

  let op_code t =
    let byte = to_byte t in
    let op_code = Array.init 4 ~f:(fun i -> byte.(i)) in
    Bit_array.to_int op_code
  ;;
end

module Operand = struct
  type t =
    | None
    | Value of { value : int }
    | Address of { address : Address.t }
    | Label of { instruction_pointer : int }

  let to_byte t ~label_resolution : _ option =
    let of_int_exn = Byte.of_int_exn in
    match (t : t) with
    | None -> None
    | Value { value } -> Some (of_int_exn value)
    | Address { address } -> Some (of_int_exn (Address.to_int address))
    | Label { instruction_pointer } ->
      Some (of_int_exn label_resolution.(instruction_pointer))
  ;;
end

module Instruction_code = struct
  type t =
    { operation : Operation.t
    ; operand : Operand.t
    }

  let size t =
    match t.operand with
    | None -> 1
    | Value _ | Address _ | Label _ -> 2
  ;;

  let of_instruction (instruction : int Instruction.t) : t =
    match instruction with
    | Nop -> { operation = Nop; operand = None }
    | Add -> { operation = Add; operand = None }
    | And -> { operation = And; operand = None }
    | Swc -> { operation = Swc; operand = None }
    | Cmp -> { operation = Cmp; operand = None }
    | Not { register_name = R0 } -> { operation = Not_R0; operand = None }
    | Not { register_name = R1 } -> { operation = Not_R1; operand = None }
    | Gof -> { operation = Gof; operand = None }
    | Jmp { label } ->
      { operation = Jmp; operand = Label { instruction_pointer = label } }
    | Jmn { label } ->
      { operation = Jmn; operand = Label { instruction_pointer = label } }
    | Jmz { label } ->
      { operation = Jmz; operand = Label { instruction_pointer = label } }
    | Store { register_name; address } ->
      { operation =
          (match register_name with
           | R0 -> Store_R0
           | R1 -> Store_R1)
      ; operand = Address { address }
      }
    | Write { register_name; address } ->
      { operation =
          (match register_name with
           | R0 -> Store_R0
           | R1 -> Store_R1)
      ; operand = Address { address = Address.to_int address + 128 |> Address.of_int }
      }
    | Load_address { address; register_name } ->
      { operation =
          (match register_name with
           | R0 -> Load_R0
           | R1 -> Load_R1)
      ; operand = Address { address }
      }
    | Load_value { value; register_name } ->
      { operation =
          (match register_name with
           | R0 -> Load_value_R0
           | R1 -> Load_value_R1)
      ; operand = Value { value }
      }
    | Sleep -> { operation = Sleep; operand = None }
  ;;
end

type t = Byte.t array [@@deriving equal, sexp_of]

let of_text_file_exn ~path =
  let q = Queue.create () in
  let file_contents =
    try Stdio.In_channel.read_all (path |> Fpath.to_string) with
    | Sys_error (m : string) -> Err.raise ~loc:(Loc.in_file ~path) [ Pp.text m ]
  in
  let lines = String.split_lines file_contents in
  let file_cache = Loc.File_cache.create ~path ~file_contents in
  List.iteri lines ~f:(fun i line ->
    let loc = Loc.in_file_line ~file_cache ~line:(Int.succ i) in
    if not (String.is_prefix line ~prefix:"//")
    then (
      let length = String.length line in
      let all_01 =
        String.for_all line ~f:(function
          | '0' | '1' -> true
          | _ -> false)
      in
      if length <> 8 || not all_01
      then
        Err.raise
          ~loc
          [ Pp.text "Invalid line, expected a line of length 8 containing chars 0-1 only."
          ];
      Queue.enqueue q (Bit_array.of_01_chars_in_string line)));
  Queue.to_array q
;;

let of_instructions (instructions : int Instruction.t array) =
  let label_resolution =
    (* Because some instructions are encoded on 1 byte, and others on 2, there
       is a shift in the labels that occurs. This table allows the mapping to be
       kept track of. *)
    Array.create ~len:(Array.length instructions) 0
  in
  let shift = ref 0 in
  let machine_operations =
    Array.mapi instructions ~f:(fun i instruction ->
      label_resolution.(i) <- !shift;
      let machine_operation = Instruction_code.of_instruction instruction in
      shift := !shift + Instruction_code.size machine_operation;
      machine_operation)
  in
  let expected_len = !shift in
  let bytes = Queue.create () in
  Array.iter machine_operations ~f:(fun { operation; operand } ->
    let first_byte = Operation.to_byte operation in
    Queue.enqueue bytes first_byte;
    match Operand.to_byte operand ~label_resolution with
    | None -> ()
    | Some second_byte -> Queue.enqueue bytes second_byte);
  let machine_code = Queue.to_array bytes in
  assert (Array.length machine_code = expected_len);
  machine_code
;;

let to_instructions (bytes : t) ~path =
  let file_contents = In_channel.read_all (path |> Fpath.to_string) in
  let file_cache = Loc.File_cache.create ~path ~file_contents in
  let size = Array.length bytes in
  let label_resolution =
    (* Because some instructions are encoded on 1 byte, and others on 2, there
       is a shift in the labels that occurs. This table allows the mapping to be
       kept track of. *)
    Array.create ~len:size 0
  in
  let resolve_label label = label_resolution.(label) in
  let bytes = Queue.of_array (Array.mapi bytes ~f:(fun i byte -> i + 1, byte)) in
  let results : int Instruction.t Queue.t = Queue.create () in
  let emit i = Queue.enqueue results i in
  while not (Queue.is_empty bytes) do
    label_resolution.(size - Queue.length bytes) <- Queue.length results;
    let line, byte = Queue.dequeue_exn bytes in
    let loc = Loc.in_file_line ~file_cache ~line in
    let operation =
      match Operation.of_byte byte with
      | Some operation -> operation
      | None ->
        Err.raise ~loc [ Pp.textf "Invalid byte code '%s'." (Bit_array.to_string byte) ]
    in
    let second_byte () =
      match Queue.dequeue bytes with
      | Some (_, byte) -> byte |> Bit_array.to_int
      | None ->
        Err.raise
          ~loc
          [ Pp.text "Invalid executable."
          ; Pp.textf
              "Operation '%s' is expected to be followed by another byte."
              (Operation.to_string operation)
          ]
    in
    emit
      (match operation with
       | Nop -> Nop
       | Add -> Add
       | And -> And
       | Swc -> Swc
       | Cmp -> Cmp
       | Not_R0 -> Not { register_name = R0 }
       | Not_R1 -> Not { register_name = R1 }
       | Gof -> Gof
       | Sleep -> Sleep
       | Jmp -> Jmp { label = second_byte () }
       | Jmn -> Jmn { label = second_byte () }
       | Jmz -> Jmz { label = second_byte () }
       | (Store_R0 | Store_R1) as store ->
         let register_name : Register_name.t =
           match store with
           | Store_R0 -> R0
           | Store_R1 -> R1
           | _ -> assert false
         in
         let address = second_byte () in
         if address >= 128
         then Write { register_name; address = address - 128 |> Address.of_int }
         else Store { register_name; address = address |> Address.of_int }
       | Load_R0 ->
         Load_address { address = second_byte () |> Address.of_int; register_name = R0 }
       | Load_R1 ->
         Load_address { address = second_byte () |> Address.of_int; register_name = R1 }
       | Load_value_R0 -> Load_value { value = second_byte (); register_name = R0 }
       | Load_value_R1 -> Load_value { value = second_byte (); register_name = R1 })
  done;
  Queue.to_array results
  |> Array.map ~f:(fun instruction -> Instruction.map instruction ~f:resolve_label)
;;

module For_testing = struct
  module Operation = Operation
end
