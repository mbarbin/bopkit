open! Import

let main =
  Command.basic
    ~summary:"echo from stdin to stdout with a setting of frequency"
    (let open Command.Let_syntax in
     let%map_open f = flag "f" (required int) ~doc:" number of cycles per second"
     and as_if_started_at_midnight =
       flag "m" no_arg ~doc:" catch-up as if it had run from midnight"
     in
     fun () ->
       let bopkit_sleeper =
         Bopkit_sleeper.create ~frequency:(float_of_int f) ~as_if_started_at_midnight
       in
       with_return (fun { return } ->
         while true do
           match In_channel.(input_line stdin) with
           | None -> return ()
           | Some line ->
             Bopkit_sleeper.sleep bopkit_sleeper;
             print_endline line
         done))
;;
