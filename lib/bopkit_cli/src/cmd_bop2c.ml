(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let main =
  Command.make
    ~summary:"Translate a bop project into a standalone C file."
    (let open Command.Std in
     let+ path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"Specify the input file."
     and+ () = Log_cli.set_config ()
     and+ bopkit_compiler_config = Bopkit_compiler.Config.arg in
     let circuit =
       Bopkit_compiler.circuit_of_netlist ~path ~config:bopkit_compiler_config
     in
     Bopkit_to_c.emit_c_code ~circuit ~to_:stdout)
;;
