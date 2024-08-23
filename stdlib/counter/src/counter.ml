let counter ~width ~frequency =
  let bit_counter = Bit_counter.create ~len:width in
  let bopkit_sleeper =
    Bopkit_sleeper.create
      ~frequency:(Float.of_int (Option.value frequency ~default:1))
      ~as_if_started_at_midnight:false
  in
  Bopkit_block.Method.main
    ~input_arity:Empty
    ~output_arity:(Bus { width })
    ~f:(fun ~input:() ~output ->
      if Option.is_some frequency then Bopkit_sleeper.sleep bopkit_sleeper;
      Bit_counter.blit_next_value bit_counter ~dst:output ~dst_pos:0)
;;

let main =
  Bopkit_block.main
    (let%map_open.Command width = Arg.named [ "N" ] Param.int ~doc:"number of bits"
     and frequency =
       Arg.named_opt [ "f" ] Param.int ~doc:"number of cycles per second (default to max)"
     in
     Bopkit_block.create ~name:"counter" ~main:(counter ~width ~frequency) ())
;;
