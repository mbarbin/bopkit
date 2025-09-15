(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

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
  let t = Unix.localtime (Unix.time ()) in
  Float.of_int ((t.tm_hour * 3600) + (t.tm_min * 60) + t.tm_sec)
;;

let start t =
  t.n <- 0;
  t.start
  <- (Unix.gettimeofday () -. if t.as_if_started_at_midnight then whattimeisit () else 0.);
  t.started <- true
;;

let wait ~(seconds : float) =
  if Float.( > ) seconds 0.0
  then (
    try
      (* This expression allows to wait for a number of seconds
         expressed as a float. *)
      ignore
        (Unix.select [] [] [] seconds
         : Unix.file_descr list * Unix.file_descr list * Unix.file_descr list)
    with
    | Unix.Unix_error (_, "select", _) -> ())
;;

let sleep t =
  if t.started
  then (
    if t.n = Int.max_value then start t;
    t.n <- Int.succ t.n;
    let advance = t.start +. (Float.of_int t.n *. t.period) -. Unix.gettimeofday () in
    wait ~seconds:advance)
  else start t
;;
