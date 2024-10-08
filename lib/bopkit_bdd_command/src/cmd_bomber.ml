let main =
  Command.make
    ~summary:"generate random boolean functions with partial specification"
    (let%map_open.Command do_not_care_probability =
       Arg.named
         [ "p" ]
         Param.int
         ~docv:"[0-100]"
         ~doc:"proportion of unspecified bits in %"
     and address =
       Arg.named [ "AD" ] Param.int ~docv:"N" ~doc:"number of bits of addresses"
     and word_length =
       Arg.named
         [ "WL" ]
         Param.int
         ~docv:"N"
         ~doc:"word length - number of bits of results"
     and probability_1 =
       Arg.named
         [ "vdd" ]
         Param.int
         ~docv:"[0-100]"
         ~doc:"proportion of 1 in specified bits"
     in
     Random.self_init ();
     let pbm : Partial_bit_matrix.t =
       Bit_matrix.init_matrix_linear
         ~dimx:(Int.pow 2 address)
         ~dimy:word_length
         ~f:(fun (_ : int) ->
           let t = Random.int 100 in
           if t < do_not_care_probability (* generate a don't care bit *)
           then None
           else Some (Random.int 100 < probability_1))
     in
     Partial_bit_matrix.to_text_channel pbm Stdio.stdout)
;;
