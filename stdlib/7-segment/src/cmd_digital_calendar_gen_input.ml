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

let now () = Caml_unix.localtime (Caml_unix.time ())

type t = bool array

let blit_time (t : t) (tm : Caml_unix.tm) =
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
  Digital_calendar.Decoded.blit
    { hour = tm.tm_hour
    ; minute = tm.tm_min
    ; second = tm.tm_sec
    ; day = tm.tm_mday
    ; month = tm.tm_mon + 1
    ; year = tm.tm_year
    }
    ~dst:t
;;

let print (t : t) =
  let buffer = Buffer.create 91 in
  Array.iter t ~f:(fun v -> Buffer.add_char buffer (if v then '1' else '0'));
  print_endline (Buffer.contents buffer)
;;

let main =
  Command.basic
    ~summary:"generate digital-calendar input"
    (let open Command.Let_syntax in
     let%map_open () = return () in
     fun () ->
       let t = Array.create ~len:91 false in
       while true do
         Core_thread.delay 0.2;
         blit_time t (now ());
         print t
       done)
;;
