open! Core

let day_of_week = function
  | 1 -> [| 1; 0; 0; 0; 0; 0; 0 |]
  | 2 -> [| 0; 1; 0; 0; 0; 0; 0 |]
  | 3 -> [| 0; 0; 1; 0; 0; 0; 0 |]
  | 4 -> [| 0; 0; 0; 1; 0; 0; 0 |]
  | 5 -> [| 0; 0; 0; 0; 1; 0; 0 |]
  | 6 -> [| 0; 0; 0; 0; 0; 1; 0 |]
  | 7 -> [| 0; 0; 0; 0; 0; 0; 1 |]
  | 0 -> [| 0; 0; 0; 0; 0; 0; 1 |]
  | _ -> failwith "day_of_week"
;;

let whattimeisit () = Caml_unix.localtime (Caml_unix.time ())

type t = bool array

let set_tab_of_time (t : t) (tm : Caml_unix.tm) =
  assert (Array.length t = 91);
  let () =
    let day_of_week =
      day_of_week tm.tm_wday
      |> Array.map ~f:(function
           | 1 -> true
           | 0 -> false
           | _ -> assert false)
    in
    Array.blit ~src:day_of_week ~src_pos:0 ~dst:t ~dst_pos:42 ~len:7
  in
  let set dst_pos digit =
    Seven_segment_display.Seven_segment_code.blit ~digit ~dst:t ~dst_pos
  in
  set 0 (tm.tm_sec mod 10);
  set 7 (tm.tm_sec / 10);
  set 14 (tm.tm_min mod 10);
  set 21 (tm.tm_min / 10);
  set 28 (tm.tm_hour mod 10);
  set 35 (tm.tm_hour / 10);
  set 49 (tm.tm_mday mod 10);
  set 56 (tm.tm_mday / 10);
  set 63 ((tm.tm_mon + 1) mod 10);
  set 70 ((tm.tm_mon + 1) / 10);
  set 77 (tm.tm_year mod 10);
  set 84 (tm.tm_year / 10 mod 10)
;;

let print (t : t) =
  let buffer = Buffer.create 91 in
  Array.iter t ~f:(fun v -> Buffer.add_char buffer (if v then '1' else '0'));
  print_endline (Buffer.contents buffer)
;;

let () =
  let t = Array.create ~len:91 false in
  while true do
    Caml_threads.Thread.delay 0.2;
    set_tab_of_time t (whattimeisit ());
    print t;
    Out_channel.flush stdout
  done
;;
