(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let () =
  Cmdlang_cmdliner_runner.run
    Seven_segment_display.Main.digital_watch
    ~name:"digital_watch"
    ~version:"%%VERSION%%"
;;
