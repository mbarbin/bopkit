type t =
  { with_cycle : bool
  ; number_of_programs : int
  ; generated_files_prefix : string
  ; subleq_simulator : Subleq_simulator.t
  ; input : Bit_matrix.t
  ; mutable index : int
  }

let create ~architecture ~with_cycle ~number_of_programs ~generated_files_prefix =
  let subleq_simulator = Subleq_simulator.create ~architecture in
  let length = Int.pow 2 architecture in
  let input = Array.make_matrix ~dimx:length ~dimy:architecture false in
  { with_cycle
  ; number_of_programs
  ; generated_files_prefix
  ; subleq_simulator
  ; input
  ; index = 0
  }
;;

let blit_input_with_random_values t =
  let length = Array.length t.input in
  for i = 0 to pred length do
    let r = Random.int length in
    Bit_array.blit_int ~src:r ~dst:t.input.(i)
  done
;;

let generate_one t =
  let found_program = ref false in
  while not !found_program do
    blit_input_with_random_values t;
    Subleq_simulator.reset_exn t.subleq_simulator t.input;
    found_program
    := match Subleq_simulator.run t.subleq_simulator with
       | Success -> not t.with_cycle
       | Program_does_not_terminate -> t.with_cycle
  done;
  t.index <- t.index + 1;
  let index_string =
    sprintf "%0*d" (String.length (Int.to_string t.number_of_programs)) t.index
  in
  let input_file = sprintf "%s%s.input" t.generated_files_prefix index_string in
  Printf.printf "[ %s --> ] Saving text of RAM input : %s\n" index_string input_file;
  Out_channel.with_file input_file ~f:(fun input_oc ->
    Bit_matrix.to_text_channel t.input input_oc);
  let output_file = sprintf "%s%s.output" t.generated_files_prefix index_string in
  Printf.printf "[ %s --> ] Saving text of RAM image : %s\n" index_string output_file;
  Out_channel.with_file output_file ~f:(fun output_oc ->
    Subleq_simulator.print_memory t.subleq_simulator ~out_channel:output_oc)
;;

let generate_all t =
  while t.index < t.number_of_programs do
    generate_one t
  done
;;
