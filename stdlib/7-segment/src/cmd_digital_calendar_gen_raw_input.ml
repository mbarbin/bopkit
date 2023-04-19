open! Core

let expected_octets = 8

let set_binary_value_in_array ~dst ~dst_pos ~value ~len =
  let cv = ref value in
  for i = 0 to pred len do
    let rem = !cv mod 2 in
    dst.(dst_pos + i) <- rem;
    cv := !cv / 2
  done
;;

let now () = Core_unix.localtime (Core_unix.time ())

type t = int array

let blit_time (t : t) (tm : Core_unix.tm) =
  (* assert tab is a expected_octets * 8 -length int array *)
  let set value dst_pos = set_binary_value_in_array ~dst:t ~dst_pos ~value ~len:8 in
  set tm.tm_sec 0;
  set tm.tm_min 8;
  set tm.tm_hour 16;
  set (pred tm.tm_mday) 32;
  set tm.tm_mon 40;
  set (tm.tm_year mod 100) 48
;;

let print (t : t) =
  let buffer = Buffer.create 42 in
  Array.iter t ~f:(fun v -> Buffer.add_string buffer (Int.to_string v));
  print_endline (Buffer.contents buffer)
;;

let main =
  Command.basic
    ~summary:"generate digital-calendar raw-input"
    (let open Command.Let_syntax in
     let%map_open () = return () in
     fun () ->
       let t = Array.create ~len:(expected_octets * 8) 0 in
       while true do
         Core_thread.delay 0.2;
         blit_time t (now ());
         print t
       done)
;;
