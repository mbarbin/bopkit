type t =
  { filenames : string list
  ; parameters : Bopkit.Netlist.parameter list
  ; memories : Bopkit.Netlist.memory list
  ; external_blocks : Bopkit.Netlist.external_block list
  ; blocks : Bopkit.Netlist.block list
  }
[@@deriving sexp_of]

let empty =
  { filenames = []; parameters = []; memories = []; external_blocks = []; blocks = [] }
;;

let concat ts =
  let q_filenames = Queue.create () in
  let q_parameters = Queue.create () in
  let q_memories = Queue.create () in
  let q_external_blocks = Queue.create () in
  let q_blocks = Queue.create () in
  List.iter ts ~f:(fun { filenames; parameters; memories; external_blocks; blocks } ->
    List.iter filenames ~f:(Queue.enqueue q_filenames);
    List.iter parameters ~f:(Queue.enqueue q_parameters);
    List.iter memories ~f:(Queue.enqueue q_memories);
    List.iter external_blocks ~f:(Queue.enqueue q_external_blocks);
    List.iter blocks ~f:(Queue.enqueue q_blocks));
  { filenames = Queue.to_list q_filenames
  ; parameters = Queue.to_list q_parameters
  ; memories = Queue.to_list q_memories
  ; external_blocks = Queue.to_list q_external_blocks
  ; blocks = Queue.to_list q_blocks
  }
;;
