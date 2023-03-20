(* Test, envoyer les bonnes infos pour calend.ml en pipe *)

(* #load "unix.cma";; *)

(* etant donne un tableau, un index de debut, et une longueur, 
   rend la valeur decimale codée en binaire dans le tableau *)

(* Version avec les valeurs de la date de 0 a n-1 *)

(* Ne pas lire necessairement les 256 octets en pipe *)

let expected_octets = 8

let val_of_bin_array tab index long =
  let rec aux accu i =
    if i = index + long then accu else aux ((accu * 2) + tab.(i)) (succ i)
  in
  aux 0 index
;;

let unite_dizaine i = i mod 10, i / 10

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
  | value ->
    let open Core in
    raise_s [%sexp "dec7", [%here], { value : int }]
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

(* le tableau de source est tres long, on ne lit que le debut *)
let update_tabs source tab =
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
    let u, d = unite_dizaine (val_of_bin_array source (long * i) long) in
    set (2 * i * 7) u;
    set (((2 * i) + 1) * 7) d
  done;
  let jour = succ (val_of_bin_array source (long * 3) long) in
  set_by_fct day_of_week 42 jour;
  for i = 0 to 2 do
    if i = 2
    then (
      let u, d = unite_dizaine (val_of_bin_array source (long * (4 + i)) long) in
      set ((2 * i * 7) + 49) u;
      set ((((2 * i) + 1) * 7) + 49) d)
    else (
      let u, d = unite_dizaine (succ (val_of_bin_array source (long * (4 + i)) long)) in
      set ((2 * i * 7) + 49) u;
      set ((((2 * i) + 1) * 7) + 49) d)
  done
;;

let () =
  let length_entree = expected_octets * 8 in
  let length_sortie = 91 in
  let entree = Array.make length_entree 0 in
  let sortie = Array.make length_sortie 0 in
  while true do
    let line = input_line stdin in
    if String.length line <> length_entree
    then (
      Printf.printf "Length : %d, expected %d.\n" (String.length line) length_entree;
      flush stdout)
    else (
      for i = 0 to pred (String.length line) do
        entree.(i) <- val_of_char line.[i]
      done;
      update_tabs entree sortie;
      Array.iter print_int sortie;
      Printf.printf "\n";
      flush stdout)
  done
;;
