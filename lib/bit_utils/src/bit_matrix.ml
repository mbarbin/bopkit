open! Core

type t = Bit_array.t array [@@deriving compare, equal, sexp_of]

let init_matrix_linear ~dimx ~dimy ~f =
  let t = Array.create ~len:dimx [||] in
  for i = 0 to pred dimx do
    let offset = i * dimy in
    t.(i) <- Array.init dimy ~f:(fun j -> f (offset + j))
  done;
  t
;;

let of_bit_array ~dimx ~dimy code =
  let len = Array.length code in
  init_matrix_linear ~dimx ~dimy ~f:(fun i -> i < len && code.(i))
;;

let of_text_file ~dimx ~dimy ~filename =
  of_bit_array ~dimx ~dimy (Bit_array.of_text_file ~filename)
;;

let to_text_channel t oc =
  Array.iter t ~f:(fun word ->
    Out_channel.output_string oc (Bit_array.to_string word);
    Out_channel.newline oc)
;;

let to_text_file t ~filename =
  Out_channel.with_file filename ~f:(fun oc -> to_text_channel t oc)
;;

let dimx t = Array.length t
let dimy t = if dimx t > 0 then Array.length t.(0) else 0
