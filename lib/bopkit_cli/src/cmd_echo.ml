let main =
  Command.make
    ~summary:"echo from stdin to stdout with a setting of frequency"
    (let%map_open.Command f =
       Arg.named [ "f" ] Param.int ~doc:"number of cycles per second"
     and as_if_started_at_midnight =
       Arg.flag [ "m" ] ~doc:"catch-up as if it had run from midnight"
     in
     let bopkit_sleeper =
       Bopkit_sleeper.create ~frequency:(Float.of_int f) ~as_if_started_at_midnight
     in
     With_return.with_return (fun { return } ->
       while true do
         match In_channel.(input_line stdin) with
         | None -> return ()
         | Some line ->
           Bopkit_sleeper.sleep bopkit_sleeper;
           print_endline line
       done))
;;
