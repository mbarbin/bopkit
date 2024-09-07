let exec_cmd =
  Command.make
    ~summary:"execute a process file as an external bloc"
    (let%map_open.Command n = Arg.named [ "N" ] Param.int ~docv:"N" ~doc:"architecture"
     and path =
       Arg.named
         [ "f" ]
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"input process file"
     and () = Err_cli.set_config () in
     let program = Parsing_utils.parse_file_exn (module Bopkit_process_syntax) ~path in
     match Bopkit_process_interpreter.run_program ~architecture:n ~program with
     | Ok () -> ()
     | Error e -> Err.raise_s "Aborted execution" [%sexp (e : Error.t)])
;;

let fmt_cmd =
  Auto_format.fmt_cmd
    (module struct
      let language_id = "bopkit-process"
      let extensions = [ ".bpp" ]
    end)
    (module Bopkit_process.Program)
    (module Bopkit_process_syntax)
    (module Bopkit_process_pp.Program)
;;

let main =
  Command.group ~summary:"Bopkit Process File Tool" [ "exec", exec_cmd; "fmt", fmt_cmd ]
;;
