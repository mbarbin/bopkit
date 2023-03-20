open! Core

let exec_cmd =
  Command.basic
    ~summary:"execute a process file as an external bloc"
    (let open Command.Let_syntax in
     let%map_open n = flag "N" (required int) ~doc:"N architecture"
     and filename = flag "f" (required string) ~doc:"FILE input process file"
     and config = Error_log.Config.param in
     Error_log.report_and_exit ~config (fun error_log ->
       let program =
         Parsing_utils.parse_file_exn (module Bopkit_process_syntax) ~filename ~error_log
       in
       Bopkit_process_interpreter.run_program ~error_log ~architecture:n ~program))
;;

let fmt_cmd =
  Fmt_command.fmt_cmd
    (module Bopkit_process.Program)
    (module Bopkit_process_syntax)
    (module Bopkit_process_pp.Program)
;;

let main =
  Command.group ~summary:"Bopkit Process File Tool" [ "exec", exec_cmd; "fmt", fmt_cmd ]
;;
