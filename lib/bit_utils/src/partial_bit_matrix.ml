type t = Partial_bit_array.t array [@@deriving compare, equal, sexp_of]

let of_partial_bit_array ~dimx ~dimy code =
  let len = Array.length code in
  Bit_matrix.init_matrix_linear ~dimx ~dimy ~f:(fun i ->
    if i < len then code.(i) else None)
;;

let of_text_file ~dimx ~dimy ~path =
  of_partial_bit_array ~dimx ~dimy (Partial_bit_array.of_text_file ~path)
;;

let to_text_channel t oc =
  Array.iter t ~f:(fun word ->
    Out_channel.output_string oc (Partial_bit_array.to_string word);
    Out_channel.newline oc)
;;

let to_text_file t ~path =
  Out_channel.with_file (path |> Fpath.to_string) ~f:(fun oc -> to_text_channel t oc)
;;
