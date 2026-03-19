(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

(* This is to silence `dune build @unused-libs` and keeping intended deps. *)
open! Subleq_simulator

let%expect_test "empty" =
  ();
  [%expect {||}];
  ()
;;
