(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t =
  { from : int
  ; to_ : int
  }
[@@deriving equal, sexp_of]

let singleton i = { from = i; to_ = i }

let expand { from; to_ } ~f =
  let q = Queue.create () in
  let () =
    if from <= to_
    then
      for i = from to to_ do
        Queue.enqueue q (f i)
      done
    else
      for i = from downto to_ do
        Queue.enqueue q (f i)
      done
  in
  Queue.to_list q
;;

let rec expand_list l ~f =
  match l with
  | [] -> []
  | [ hd ] -> List.map (expand hd ~f) ~f:(fun t -> [ t ])
  | hd :: tl ->
    let this = expand hd ~f in
    let tl = expand_list tl ~f in
    List.concat_map this ~f:(fun e -> List.map tl ~f:(fun tl -> e :: tl))
;;
