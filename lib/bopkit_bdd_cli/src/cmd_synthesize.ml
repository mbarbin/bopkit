let main =
  Command.make
    ~summary:"Generate a .bop circuit from a boolean function with partial specification."
    (let%map_open.Command path =
       Arg.named
         [ "f" ]
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"Input file with boolean function (ascii)."
     and address =
       Arg.named [ "AD" ] Param.int ~docv:"N" ~doc:"Number of bits of addresses."
     and word_length =
       Arg.named
         [ "WL" ]
         Param.int
         ~docv:"N"
         ~doc:"Word length - number of bits of results."
     and tree_option =
       Arg.flag [ "tree" ] ~doc:"Generate a mux tree rather than a mux list."
     and block_name =
       Arg.named_opt
         [ "block-name" ]
         Param.string
         ~docv:"Block_name"
         ~doc:"The desired name for the synthesized block."
     in
     let len = Int.pow 2 address in
     let pbm = Partial_bit_matrix.of_text_file ~dimx:len ~dimy:word_length ~path in
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
     let prop = Float.of_int num_gates /. Float.of_int full_gates *. 100. in
     let gate_count =
       if tree_option
       then Printf.sprintf "[%d|%d]" full_gates num_gates
       else Printf.sprintf "[%d|%d|%d]" full_gates normalized_gates num_gates
     in
     Stdlib.Printf.printf
       "// Block synthesized by bopkit from %S\n"
       (path |> Fpath.to_string);
     Stdlib.Printf.printf "// Gate count: %s (%2.3f %c)\n" gate_count prop '%';
     print_endline "";
     Stdlib.Format.printf "%a" Bopkit_bdd.Block.pp bloc;
     Out_channel.flush stdout)
;;
