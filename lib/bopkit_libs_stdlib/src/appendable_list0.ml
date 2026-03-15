(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

(* Adapted from https://github.com/mbarbin/appendable-list.
   Originally from Jane Street's core_extended. See third-party-license/. *)

type +'a t =
  | Empty
  | Singleton of 'a
  | List of 'a * 'a * 'a list
  | Node of 'a t * 'a t * 'a t list

let empty = Empty
let singleton x = Singleton x
let append t1 t2 = Node (t1, t2, [])
let cons x t = Node (Singleton x, t, [])

let of_list = function
  | [] -> Empty
  | [ x ] -> Singleton x
  | a :: b :: c -> List (a, b, c)
;;

let concat ts = Stdlib.List.fold_left (fun acc t -> append acc t) empty ts

let fold_right =
  let rec go todo ~init ~f =
    match todo with
    | [] -> init
    | Empty :: todo -> go todo ~init ~f
    | Singleton x :: todo -> go todo ~init:(f x init) ~f
    | List (a, b, cs) :: todo ->
      let init = Stdlib.List.fold_right f cs init in
      let init = f b init in
      let init = f a init in
      go todo ~init ~f
    | Node (a, b, cs) :: todo -> go (Stdlib.List.rev_append cs (b :: a :: todo)) ~init ~f
  in
  fun t ~init ~f -> go [ t ] ~init ~f
;;

let to_list t = fold_right t ~init:[] ~f:(fun x acc -> x :: acc)

let iter =
  let rec go todo ~f =
    match todo with
    | [] -> ()
    | Empty :: todo -> go todo ~f
    | Singleton x :: todo ->
      f x;
      go todo ~f
    | List (a, b, cs) :: todo ->
      f a;
      f b;
      Stdlib.List.iter f cs;
      go todo ~f
    | Node (a, b, cs) :: todo -> go (a :: b :: (cs @ todo)) ~f
  in
  fun t ~f -> go [ t ] ~f
;;
