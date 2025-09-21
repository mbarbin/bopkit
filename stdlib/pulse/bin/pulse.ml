(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let () =
  Cmdlang_cmdliner_err_runner.run
    Bopkit_pulse.Pulse.main
    ~name:"pulse"
    ~version:"%%VERSION%%"
;;
