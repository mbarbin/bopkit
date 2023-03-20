open! Core

module Time_of_day = struct
  type t =
    { hour : int
    ; min : int
    ; sec : int
    }

  let of_unix_time (t : Caml_unix.tm) =
    { hour = t.tm_hour; min = t.tm_min; sec = t.tm_sec }
  ;;

  let now () = Caml_unix.localtime (Caml_unix.time ()) |> of_unix_time
end

type t = bool array

let blit_time (t : t) (tod : Time_of_day.t) =
  let blit dst_pos digit =
    Seven_segment_display.Seven_segment_code.blit ~digit ~dst:t ~dst_pos
  in
  blit 0 (tod.hour / 10);
  blit 7 (tod.hour mod 10);
  blit 14 (tod.min / 10);
  blit 21 (tod.min mod 10);
  blit 28 (tod.sec / 10);
  blit 35 (tod.sec mod 10)
;;

let print (t : t) =
  let buffer = Buffer.create 42 in
  Array.iter t ~f:(fun v -> Buffer.add_char buffer (if v then '1' else '0'));
  print_endline (Buffer.contents buffer)
;;

let () =
  let argv = Sys.get_argv () in
  let t : t = Array.create ~len:42 false in
  if Array.length argv > 1 && String.equal argv.(1) "--gen-unit-test-output"
  then
    for hour = 0 to 47 do
      for min = 0 to 59 do
        for sec = 0 to 59 do
          blit_time t { hour = hour mod 24; min; sec };
          print t
        done
      done
    done
  else
    while true do
      ignore (Caml_threads.Thread.delay 0.5 : unit);
      blit_time t (Time_of_day.now ());
      print t;
      Out_channel.flush stdout
    done
;;
