(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let expected_octets = 8

let val_of_bin_array ~src:tab ~pos:index ~len:long =
  let res = ref 0 in
  for i = Int.pred (index + long) downto index do
    res := (!res * 2) + tab.(i)
  done;
  !res
;;

let unite_dizaine i = i % 10, i / 10

let val_of_char = function
  | '1' -> 1
  | '0' -> 0
  | _ -> failwith "'0' ou '1' attendu"
;;

let dec7 = function
  | 0 -> 1, 0, 1, 1, 1, 1, 1
  | 1 -> 0, 0, 0, 0, 1, 1, 0
  | 2 -> 0, 1, 1, 1, 0, 1, 1
  | 3 -> 0, 1, 0, 1, 1, 1, 1
  | 4 -> 1, 1, 0, 0, 1, 1, 0
  | 5 -> 1, 1, 0, 1, 1, 0, 1
  | 6 -> 1, 1, 1, 1, 1, 0, 1
  | 7 -> 0, 0, 0, 0, 1, 1, 1
  | 8 -> 1, 1, 1, 1, 1, 1, 1
  | 9 -> 1, 1, 0, 1, 1, 1, 1
  | value -> raise_s [%sexp "dec7", [%here], { value : int }]
;;

(* code de 1 à 7 *)
let day_of_week = function
  | 1 -> 1, 0, 0, 0, 0, 0, 0
  | 2 -> 0, 1, 0, 0, 0, 0, 0
  | 3 -> 0, 0, 1, 0, 0, 0, 0
  | 4 -> 0, 0, 0, 1, 0, 0, 0
  | 5 -> 0, 0, 0, 0, 1, 0, 0
  | 6 -> 0, 0, 0, 0, 0, 1, 0
  | 7 -> 0, 0, 0, 0, 0, 0, 1
  | _ -> 0, 0, 0, 0, 0, 0, 0
;;

type t = int array

(* le tableau de source est tres long, on ne lit que le debut *)
let update_tabs source (tab : t) =
  let set_by_fct fct index v =
    let a, b, c, d, e, f, g = fct v in
    tab.(index) <- a;
    tab.(index + 1) <- b;
    tab.(index + 2) <- c;
    tab.(index + 3) <- d;
    tab.(index + 4) <- e;
    tab.(index + 5) <- f;
    tab.(index + 6) <- g
  in
  let set = set_by_fct dec7 in
  let long = 8 in
  for i = 0 to 2 do
    let u, d = unite_dizaine (val_of_bin_array ~src:source ~pos:(long * i) ~len:long) in
    set (2 * i * 7) u;
    set (((2 * i) + 1) * 7) d
  done;
  let jour = Int.succ (val_of_bin_array ~src:source ~pos:(long * 3) ~len:long) in
  set_by_fct day_of_week 42 jour;
  for i = 0 to 2 do
    if i = 2
    then (
      let u, d =
        unite_dizaine (val_of_bin_array ~src:source ~pos:(long * (4 + i)) ~len:long)
      in
      set ((2 * i * 7) + 49) u;
      set ((((2 * i) + 1) * 7) + 49) d)
    else (
      let u, d =
        unite_dizaine
          (Int.succ (val_of_bin_array ~src:source ~pos:(long * (4 + i)) ~len:long))
      in
      set ((2 * i * 7) + 49) u;
      set ((((2 * i) + 1) * 7) + 49) d)
  done
;;

let print (t : t) =
  let buffer = Buffer.create 42 in
  Array.iter t ~f:(fun v -> Buffer.add_string buffer (Int.to_string v));
  print_endline (Buffer.contents buffer)
;;

let main =
  Command.make
    ~summary:"Generate digital-calendar raw input."
    (let open Command.Std in
     let+ () = Arg.return () in
     let length_entree = expected_octets * 8 in
     let length_sortie = 91 in
     let entree = Array.create ~len:length_entree 0 in
     let sortie = Array.create ~len:length_sortie 0 in
     In_channel.iter_lines In_channel.stdin ~f:(fun line ->
       if String.length line <> length_entree
       then (
         Stdlib.Printf.eprintf
           "Length : %d, expected %d.\n"
           (String.length line)
           length_entree;
         Out_channel.flush stderr)
       else (
         for i = 0 to Int.pred (String.length line) do
           entree.(i) <- val_of_char line.[i]
         done;
         update_tabs entree sortie;
         print sortie)))
;;
