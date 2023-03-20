open! Core

let%expect_test "counter" =
  let n = 3 in
  let t = Array.create ~len:n false in
  let bit_counter = Bit_counter.create ~len:n in
  for _ = 0 to Int.pow 2 n * 2 do
    Bit_counter.blit_next_value bit_counter ~dst:t ~dst_pos:0;
    print_endline (Bit_array.to_string t)
  done;
  [%expect
    {|
    000
    100
    010
    110
    001
    101
    011
    111
    000
    100
    010
    110
    001
    101
    011
    111
    000 |}]
;;

let%expect_test "counter" =
  let t = Array.init 10 ~f:(fun i -> i mod 2 = 1) in
  let bit_counter = Bit_counter.create ~len:2 in
  for _ = 0 to 9 do
    Bit_counter.blit_next_value bit_counter ~dst:t ~dst_pos:5;
    print_endline (Bit_array.to_string t)
  done;
  [%expect
    {|
    0101000101
    0101010101
    0101001101
    0101011101
    0101000101
    0101010101
    0101001101
    0101011101
    0101000101
    0101010101 |}]
;;

let%expect_test "out of bounds" =
  let n = 3 in
  let t = Array.create ~len:n false in
  let bit_counter = Bit_counter.create ~len:n in
  Expect_test_helpers_core.require_does_raise [%here] (fun () ->
    Bit_counter.blit_next_value bit_counter ~dst:t ~dst_pos:1);
  [%expect
    {|
    (Bit_counter.blit_next_value
     "dst length is too short"
     ((bit_counter_length 3)
      (dst_pos            1)
      (dst_length         3)
      (required_length    4))) |}]
;;
