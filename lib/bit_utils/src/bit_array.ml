(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t = bool array [@@deriving compare, equal, quickcheck, sexp_of]

let enqueue_01_char_in_line ~line ~dst =
  let error ~pos sexp =
    raise_s
      [%sexp
        "Invalid bit array specification", { line : string; pos : int }, (sexp : Sexp.t)]
  in
  let len = String.length line in
  let exception Comment_suffix in
  try
    String.iteri line ~f:(fun i char ->
      match char with
      | '0' -> Queue.enqueue dst false
      | '1' -> Queue.enqueue dst true
      | '/' ->
        if i >= len - 1 || not (Char.equal line.[i + 1] '/')
        then
          error
            ~pos:i
            [%sexp "Comment character '/' is expected to be followed by another '/'"]
        else Stdlib.raise_notrace Comment_suffix
      | ' ' | '|' -> ()
      | c -> error ~pos:i [%sexp { unexpected_char = (c : Char.t) }])
  with
  | Comment_suffix -> ()
;;

let enqueue_01_char ~src ~dst =
  let lines = String.split_lines src in
  List.iter lines ~f:(fun line -> enqueue_01_char_in_line ~line ~dst)
;;

let of_01_chars_in_string s =
  let q = Queue.create () in
  enqueue_01_char ~src:s ~dst:q;
  Queue.to_array q
;;

let to_string (t : t) =
  String.init (Array.length t) ~f:(fun i -> Bit_string_encoding.Bit.to_char t.(i))
;;

let of_text_file ~path =
  let q = Queue.create () in
  In_channel.with_file (path |> Fpath.to_string) ~f:(fun ic ->
    In_channel.iter_lines ic ~f:(fun line -> enqueue_01_char ~src:line ~dst:q));
  Queue.to_array q
;;

let to_text_channel t oc = Printf.fprintf oc "%s\n" (to_string t)

let to_text_file t ~path =
  Out_channel.with_file (path |> Fpath.to_string) ~f:(fun oc -> to_text_channel t oc)
;;

let to_int bits =
  let res = ref 0 in
  for i = pred (Array.length bits) downto 0 do
    res := (!res * 2) + if bits.(i) then 1 else 0
  done;
  !res
;;

let to_signed_int bits =
  let len = Array.length bits in
  let modo = ref 1 in
  let unsigned_int =
    let res = ref 0 in
    for i = pred len downto 0 do
      modo := !modo * 2;
      res := (!res * 2) + if bits.(i) then 1 else 0
    done;
    !res
  in
  if len > 0 && bits.(pred len) then unsigned_int - !modo else unsigned_int
;;

let blit_int ~src:i ~dst:tab =
  let len = Array.length tab in
  let modo = Int.pow 2 len in
  let j = ref (i % modo) in
  for i = 0 to pred len do
    tab.(i) <- !j mod 2 = 1;
    j := !j / 2
  done
;;

let blit_init ~dst:tab ~f:fct =
  let len = Array.length tab in
  for i = 0 to pred len do
    tab.(i) <- fct i
  done
;;

module Short_sexp = struct
  type nonrec t = t

  let sexp_of_t t = Sexp.Atom (to_string t)
end
