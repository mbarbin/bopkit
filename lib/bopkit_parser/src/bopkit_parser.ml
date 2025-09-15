(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t = Bopkit.Netlist.t
type token = Parser.token

let lexer = Lexer.read
let parser lexer lexbuf = Comments_parser.wrap ~f:(fun () -> Parser.netlist lexer lexbuf)
