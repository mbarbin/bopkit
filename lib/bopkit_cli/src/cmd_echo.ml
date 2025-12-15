(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let main =
  Command.make
    ~summary:"Echo from stdin to stdout with a setting of frequency."
    (let open Command.Std in
     let+ f = Arg.named [ "f" ] Param.int ~doc:"Number of cycles per second."
     and+ as_if_started_at_midnight =
       Arg.flag [ "m" ] ~doc:"Catch-up as if it had run from midnight."
     in
     let bopkit_sleeper =
       Bopkit_sleeper.create ~frequency:(Float.of_int f) ~as_if_started_at_midnight
     in
     In_channel.iter_lines In_channel.stdin ~f:(fun line ->
       Bopkit_sleeper.sleep bopkit_sleeper;
       print_endline line))
;;
