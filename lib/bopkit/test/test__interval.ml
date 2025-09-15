(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let%expect_test "expand" =
  let test t =
    let r = Interval.expand t ~f:Fn.id in
    print_s [%sexp (r : int list)]
  in
  test { from = 0; to_ = 0 };
  [%expect {| (0) |}];
  test { from = 0; to_ = -4 };
  [%expect {| (0 -1 -2 -3 -4) |}];
  test { from = -1; to_ = 2 };
  [%expect {| (-1 0 1 2) |}];
  ()
;;

let%expect_test "expand_list" =
  let test t =
    let r = Interval.expand_list t ~f:Fn.id in
    print_s [%sexp (r : int list list)]
  in
  test [];
  [%expect {| () |}];
  test [ { from = 0; to_ = 0 } ];
  [%expect {| ((0)) |}];
  test [ { from = 0; to_ = -4 } ];
  [%expect
    {|
    ((0)
     (-1)
     (-2)
     (-3)
     (-4)) |}];
  test [ { from = -1; to_ = 2 } ];
  [%expect
    {|
    ((-1)
     (0)
     (1)
     (2)) |}];
  test [ { from = 0; to_ = 1 }; { from = 0; to_ = 2 } ];
  [%expect
    {|
    ((0 0)
     (0 1)
     (0 2)
     (1 0)
     (1 1)
     (1 2)) |}];
  ()
;;
