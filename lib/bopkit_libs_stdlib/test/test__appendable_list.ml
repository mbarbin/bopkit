(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let print_int_list t =
  Appendable_list.to_list t
  |> Stdlib.List.map string_of_int
  |> String.concat ","
  |> print_string
;;

let%expect_test "empty" =
  print_int_list Appendable_list.empty;
  [%expect {| |}];
  ()
;;

let%expect_test "singleton" =
  print_int_list (Appendable_list.singleton 42);
  [%expect {| 42 |}];
  ()
;;

let%expect_test "of_list / to_list" =
  print_int_list (Appendable_list.of_list [ 1; 2; 3 ]);
  [%expect {| 1,2,3 |}];
  ()
;;

let%expect_test "cons" =
  print_int_list (Appendable_list.cons 0 (Appendable_list.of_list [ 1; 2; 3 ]));
  [%expect {| 0,1,2,3 |}];
  ()
;;

let%expect_test "append" =
  print_int_list
    (Appendable_list.append
       (Appendable_list.of_list [ 1; 2 ])
       (Appendable_list.of_list [ 3; 4 ]));
  [%expect {| 1,2,3,4 |}];
  ()
;;

let%expect_test "nested appends" =
  let a = Appendable_list.of_list [ 1; 2 ] in
  let b = Appendable_list.of_list [ 3; 4 ] in
  let c = Appendable_list.of_list [ 5; 6 ] in
  print_int_list (Appendable_list.append (Appendable_list.append a b) c);
  [%expect {| 1,2,3,4,5,6 |}];
  print_int_list (Appendable_list.append a (Appendable_list.append b c));
  [%expect {| 1,2,3,4,5,6 |}];
  ()
;;

let%expect_test "cons + append" =
  let a = Appendable_list.of_list [ 1; 2 ] in
  let b = Appendable_list.of_list [ 3; 4 ] in
  print_int_list (Appendable_list.cons 0 (Appendable_list.append a b));
  [%expect {| 0,1,2,3,4 |}];
  ()
;;

let%expect_test "concat" =
  let a = Appendable_list.of_list [ 1; 2 ] in
  let b = Appendable_list.of_list [ 3; 4 ] in
  let c = Appendable_list.of_list [ 5; 6 ] in
  print_int_list (Appendable_list.concat [ a; b; c ]);
  [%expect {| 1,2,3,4,5,6 |}];
  ()
;;

let%expect_test "concat empty" =
  print_int_list (Appendable_list.concat []);
  [%expect {| |}];
  ()
;;

let%expect_test "iter" =
  Appendable_list.of_list [ 1; 2; 3 ]
  |> Appendable_list.iter ~f:(fun x -> Printf.printf "%d " x);
  [%expect {| 1 2 3 |}];
  ()
;;
