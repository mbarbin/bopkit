open! Core

type t =
  { period : float
  ; as_if_started_at_midnight : bool
  ; mutable start : float
  ; mutable started : bool
  ; mutable n : int
  }

let create ~frequency ~as_if_started_at_midnight =
  { period = 1. /. frequency
  ; as_if_started_at_midnight
  ; start = 0.
  ; started = false
  ; n = 0
  }
;;

(* Compute how many seconds have passed since this morning at midnight. *)
let whattimeisit () =
  let t = Caml_unix.localtime (Caml_unix.time ()) in
  float_of_int ((t.tm_hour * 3600) + (t.tm_min * 60) + t.tm_sec)
;;

let start t =
  t.n <- 0;
  t.start
  <- (Caml_unix.gettimeofday ()
      -. if t.as_if_started_at_midnight then whattimeisit () else 0.);
  t.started <- true
;;

let wait ~(seconds : float) =
  if Float.( > ) seconds 0.0
  then (
    try
      (* This expression allows to wait for a number of seconds
         expressed as a float. *)
      ignore
        (Caml_unix.select [] [] [] seconds
         : Caml_unix.file_descr list
           * Caml_unix.file_descr list
           * Caml_unix.file_descr list)
    with
    | Caml_unix.Unix_error (_, "select", _) -> ())
;;

let sleep t =
  if t.started
  then (
    if t.n = Int.max_value then start t;
    t.n <- succ t.n;
    let advance =
      t.start +. (float_of_int t.n *. t.period) -. Caml_unix.gettimeofday ()
    in
    wait ~seconds:advance)
  else start t
;;
