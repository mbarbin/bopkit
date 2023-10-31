let main =
  Command.basic
    ~summary:"generate a .bop circuit from a boolean function with partial specification"
    (let open Command.Let_syntax in
     let%map_open filename =
       flag "f" (required string) ~doc:"FILE input file with boolean function (ascii)"
     and address = flag "AD" (required int) ~doc:"N number of bits of addresses"
     and word_length =
       flag "WL" (required int) ~doc:"N word length - number of bits of results"
     and tree_option =
       flag "tree" no_arg ~doc:" generate a mux tree rather than a mux list"
     and block_name =
       flag
         "block-name"
         (optional string)
         ~doc:"Block_name the desired name for the synthesized block"
     in
     fun () ->
       let len = Int.pow 2 address in
       let pbm = Partial_bit_matrix.of_text_file ~dimx:len ~dimy:word_length ~filename in
       let muxtrees = Bopkit_bdd.Muxtree.of_partial_bit_matrix pbm in
       let bloc =
         if tree_option
         then Bopkit_bdd.Block.of_muxtrees muxtrees ?block_name ~input_size:address
         else
           Bopkit_bdd.Block.of_muxlist
             (Bopkit_bdd.Muxlist.of_muxtrees muxtrees)
             ?block_name
             ~input_size:address
       in
       let num_gates = Bopkit_bdd.Block.number_of_gates bloc in
       let full_gates = (len - 1) * word_length in
       let normalized_gates =
         List.sum (module Int) muxtrees ~f:Bopkit_bdd.Muxtree.number_of_gates
       in
       let prop = float_of_int num_gates /. float_of_int full_gates *. 100. in
       let gate_count =
         if tree_option
         then sprintf "[%d|%d]" full_gates num_gates
         else sprintf "[%d|%d|%d]" full_gates normalized_gates num_gates
       in
       Printf.printf "// Block synthesized by bopkit from %S\n" filename;
       Printf.printf "// Gate count: %s (%2.3f %c)\n" gate_count prop '%';
       print_endline "";
       Format.printf "%a" Bopkit_bdd.Block.pp bloc;
       Out_channel.flush stdout)
;;
