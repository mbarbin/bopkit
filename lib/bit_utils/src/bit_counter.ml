(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t =
  { length : int
  ; max_value : int
  ; mutable next_value : int
  }
[@@deriving sexp_of]

let create ~len:length =
  { length : int; max_value = Int.pow 2 length - 1; next_value = 0 }
;;

let blit_next_value t ~dst ~dst_pos =
  let len = Array.length dst in
  if len < dst_pos + t.length
  then
    raise_s
      [%sexp
        "Bit_counter.blit_next_value"
      , "dst length is too short"
      , { bit_counter_length = (t.length : int)
        ; dst_pos : int
        ; dst_length = (len : int)
        ; required_length = (dst_pos + t.length : int)
        }];
  let next_value = t.next_value in
  let tmp = Array.create ~len:t.length false in
  Bit_array.blit_int ~dst:tmp ~src:next_value;
  Array.blit ~src:tmp ~src_pos:0 ~dst ~dst_pos ~len:t.length;
  let next_value =
    let succ = next_value + 1 in
    if succ > t.max_value then 0 else succ
  in
  t.next_value <- next_value
;;
