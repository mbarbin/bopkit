(* Test, envoyer les bonnes infos pour calend.ml en pipe *)

(* #load "unix.cma";; *)

(* Ne pas fournir necessairement les 256 octets en pipe *)

let expected_octets = 8

let set_binaire_value_in_array tab long v index =
  let cv = ref v in
  for i = 0 to pred long do
    let reste = !cv mod 2 in
    tab.(index + long - 1 - i) <- reste;
    cv := !cv / 2
  done
;;

let whattimeisit () = Unix.localtime (Unix.time ())

let set_tab_of_time tab t =
  (* assert tab is a expected_octets * 8 -length int array *)
  let set = set_binaire_value_in_array tab 8 in
  set t.Unix.tm_sec 0;
  set t.Unix.tm_min 8;
  set t.Unix.tm_hour 16;
  (*    set (pred t.Unix.tm_wday) 24; *)
  (* jour de la semaine *)
  set (pred t.Unix.tm_mday) 32;
  set t.Unix.tm_mon 40;
  set (t.Unix.tm_year mod 100) 48
;;

let () =
  let t = Array.make (expected_octets * 8) 0 in
  while true do
    ignore
      (Unix.select [] [] [] 0.2
        : Unix.file_descr list * Unix.file_descr list * Unix.file_descr list);
    set_tab_of_time t (whattimeisit ());
    Array.iter print_int t;
    Printf.printf "\n";
    flush stdout
  done
;;
