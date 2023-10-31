let main ~ad ~wl ~filename =
  let num_addr = Int.pow 2 ad in
  let rom = Partial_bit_matrix.of_text_file ~dimx:num_addr ~dimy:wl ~filename in
  Bopkit_block.Method.main
    ~input_arity:(Tuple_2 (Bus { width = ad }, Bus { width = wl }))
    ~output_arity:Empty
    ~f:(fun ~input:(addr, word) ~output:() ->
      let i = Bit_array.to_int addr mod num_addr in
      if Partial_bit_array.conflicts rom.(i) ~with_:word
      then (
        let address = Bit_array.to_string addr in
        let expected = Partial_bit_array.to_string rom.(i) in
        let received = Bit_array.to_string word in
        eprintf "Conflict for bdd at addr '%s' (%d)\n" address i;
        eprintf "Expected = '%s'\n" expected;
        eprintf "Received = '%s'\n" received;
        Out_channel.flush stderr;
        raise_s
          [%sexp TEST_FAILURE, { address : string; expected : string; received : string }]))
;;

let main =
  Bopkit_block.main
    ~readme:(fun () ->
      {|
This block takes in a BDD truth table, an address and a result. It checks
whether the result agrees with the truth table, and if not raises an
exception. It is meant to be used as unit-test in a bopkit simulation.
|})
    (let open Command.Let_syntax in
     let%map_open ad = flag "AD" (required int) ~doc:"N number of bits of addresses"
     and wl = flag "WL" (required int) ~doc:"N number of bits of output words"
     and filename = flag "f" (required string) ~doc:"FILE the file to load" in
     Bopkit_block.create ~name:"bdd-checker" ~main:(main ~ad ~wl ~filename) ())
;;
