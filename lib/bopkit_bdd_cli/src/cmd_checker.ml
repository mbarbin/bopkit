let main ~ad ~wl ~path =
  let num_addr = Int.pow 2 ad in
  let rom = Partial_bit_matrix.of_text_file ~dimx:num_addr ~dimy:wl ~path in
  Bopkit_block.Method.main
    ~input_arity:(Tuple_2 (Bus { width = ad }, Bus { width = wl }))
    ~output_arity:Empty
    ~f:(fun ~input:(addr, word) ~output:() ->
      let i = Bit_array.to_int addr % num_addr in
      if Partial_bit_array.conflicts rom.(i) ~with_:word
      then (
        let address = Bit_array.to_string addr in
        let expected = Partial_bit_array.to_string rom.(i) in
        let received = Bit_array.to_string word in
        Stdlib.Printf.eprintf "Conflict for bdd at addr '%s' (%d)\n" address i;
        Stdlib.Printf.eprintf "Expected = '%s'\n" expected;
        Stdlib.Printf.eprintf "Received = '%s'\n" received;
        Out_channel.flush stderr;
        raise_s
          [%sexp TEST_FAILURE, { address : string; expected : string; received : string }]))
;;

let main =
  Bopkit_block.main
    ~readme:(fun () ->
      "This block takes in a BDD truth table, an address and a result. It checks whether \
       the result agrees with the truth table, and if not raises an exception. It is \
       meant to be used as unit-test in a bopkit simulation.")
    (let%map_open.Command ad =
       Arg.named [ "AD" ] Param.int ~docv:"N" ~doc:"Number of bits of addresses."
     and wl =
       Arg.named [ "WL" ] Param.int ~docv:"N" ~doc:"Number of bits of output words."
     and path =
       Arg.named
         [ "f" ]
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"The file to load."
     in
     Bopkit_block.create ~name:"bdd-checker" ~main:(main ~ad ~wl ~path) ())
;;
