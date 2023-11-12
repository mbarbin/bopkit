module With_labels = struct
  module Line = struct
    type t =
      { label_introduction : Label.t option
      ; instruction : Label.t Instruction.t
      }
    [@@deriving equal, sexp_of]
  end

  type t = Line.t array [@@deriving equal, sexp_of]

  let disassemble (t : t) =
    let program : Program.Top_level_construct.t Queue.t = Queue.create () in
    Array.iter t ~f:(fun { label_introduction; instruction } ->
      Option.iter label_introduction ~f:(fun label ->
        (* As of now it is not clear how we build values of type [t], it is
           possible we will determine that it is possible to obtain some real
           positions from it. To be determined. *)
        let label = With_loc.with_dummy_pos label in
        Queue.enqueue program (Label_introduction { label }));
      Queue.enqueue
        program
        (Assembly_instruction
           { assembly_instruction =
               Instruction.disassemble instruction ~disassemble_label:Fn.id
           }));
    Queue.to_list program
  ;;
end

module Instruction_pointer = struct
  type t = int [@@deriving equal, sexp_of]

  let to_int i = i
end

type t = Instruction_pointer.t Instruction.t array [@@deriving equal, sexp_of]

let with_labels (t : t) : With_labels.t =
  let int_len = Array.length t |> Int.to_string |> String.length in
  let make_label i = sprintf "%0*d" int_len i |> Label.of_string in
  let labels = Hashtbl.create (module Int) in
  let instructions =
    Array.map t ~f:(fun instruction ->
      Instruction.map instruction ~f:(fun address ->
        match Hashtbl.find labels address with
        | Some label -> label
        | None ->
          let label = make_label address in
          Hashtbl.set labels ~key:address ~data:label;
          label))
  in
  Array.mapi instructions ~f:(fun i instruction ->
    { With_labels.Line.label_introduction = Hashtbl.find labels i; instruction })
;;

let disassemble t = With_labels.disassemble (with_labels t)

let resolve_labels (t : With_labels.t) =
  let labels = Hashtbl.create (module Label) in
  Array.iteri t ~f:(fun i { label_introduction; instruction = _ } ->
    match label_introduction with
    | None -> ()
    | Some label -> Hashtbl.add_exn labels ~key:label ~data:i);
  Array.mapi t ~f:(fun i { label_introduction = _; instruction } ->
    Instruction.map instruction ~f:(fun label ->
      match Hashtbl.find labels label with
      | Some instruction_pointer -> instruction_pointer
      | None ->
        raise_s
          [%sexp
            "Undefined label"
            , [%here]
            , { i : int; instruction : Label.t Instruction.t; label : Label.t }]))
;;

let to_machine_code (t : t) = Machine_code.of_instructions t

module Machine_code = struct
  type t = Machine_code.t [@@deriving equal, sexp_of]

  let disassemble bytes ~path ~error_log =
    disassemble (Machine_code.to_instructions bytes ~path ~error_log)
  ;;
end
