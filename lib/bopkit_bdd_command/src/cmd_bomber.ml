open! Core

let main =
  Command.basic
    ~summary:"generate random boolean functions with partial specification"
    (let open Command.Let_syntax in
     let%map_open do_not_care_probability =
       flag "p" (required int) ~doc:"[0-100] proportion of unspecified bits"
     and address = flag "AD" (required int) ~doc:"N number of bits of addresses"
     and word_length =
       flag "WL" (required int) ~doc:"N word length - number of bits of results"
     and probability_1 =
       flag "vdd" (required int) ~doc:"[0-100] proportion of 1 in specified bits"
     in
     fun () ->
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
       Partial_bit_matrix.to_text_channel pbm stdout)
;;
