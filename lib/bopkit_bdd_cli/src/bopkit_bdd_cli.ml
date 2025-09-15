(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let main =
  Command.group
    ~summary:"Bopkit Binary Decision Diagram Tool."
    [ "checker", Cmd_checker.main
    ; "synthesize", Cmd_synthesize.main
    ; "bomber", Cmd_bomber.main
    ]
;;
