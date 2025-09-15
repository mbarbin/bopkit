(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t = Bit_array.t array [@@deriving equal]

let sexp_of_t t =
  Array.mapi t ~f:(fun i v -> i, Bit_array.to_int v) |> [%sexp_of: (int * int) Array.t]
;;

let create ~len = Array.init len ~f:(fun _ -> Array.create ~len:8 false)
let length t = Array.length t

let set t ~address ~value =
  if address < 0 || address >= Array.length t
  then raise_s [%sexp "out of bounds", [%here], { t : t; address : int; value : int }];
  Bit_array.blit_int ~src:value ~dst:t.(address)
;;

let to_string t =
  let buf = Buffer.create (Array.length t * 8) in
  Array.iter t ~f:(fun b -> Buffer.add_string buf (Bit_array.to_string b));
  Buffer.contents buf
;;
