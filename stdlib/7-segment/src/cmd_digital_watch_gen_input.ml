module Time_of_day = struct
  type t =
    { hour : int
    ; min : int
    ; sec : int
    }

  let of_unix_time (t : Unix.tm) = { hour = t.tm_hour; min = t.tm_min; sec = t.tm_sec }
  let now () = Unix.localtime (Unix.time ()) |> of_unix_time
end

type t = bool array

let blit_time (t : t) (tod : Time_of_day.t) =
  Digital_watch.Decoded.blit
    { hour = tod.hour; minute = tod.min; second = tod.sec }
    ~dst:t
;;

let print (t : t) =
  let buffer = Buffer.create 42 in
  Array.iter t ~f:(fun v -> Buffer.add_char buffer (if v then '1' else '0'));
  print_endline (Buffer.contents buffer)
;;

let main =
  Command.make
    ~summary:"generate digital-calendar input"
    (let%map_open.Command gen_unit_test_output =
       Arg.flag [ "gen-unit-test-output" ] ~doc:"generate expected output"
     in
     let t : t = Array.create ~len:42 false in
     if gen_unit_test_output
     then
       for hour = 0 to 47 do
         for min = 0 to 59 do
           for sec = 0 to 59 do
             blit_time t { hour = hour % 24; min; sec };
             print t
           done
         done
       done
     else
       while true do
         ignore (Thread.delay 0.5 : unit);
         blit_time t (Time_of_day.now ());
         print t
       done)
;;
