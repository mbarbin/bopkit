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
     and () = Log_cli.set_config () in
     let program = Parsing_utils.parse_file_exn (module Bopkit_process_parser) ~path in
     match Bopkit_process_interpreter.run_program ~architecture:n ~program with
     | Ok () -> ()
     | Error e ->
       let errs =
         match Error.sexp_of_t e with
         | List [ Atom msg; sexp ] -> [ Pp.text msg; Err.sexp sexp ]
         | sexp -> [ Err.sexp sexp ]
       in
       Err.raise (Pp.text "Aborted execution." :: errs))
;;

let fmt_cmd =
  Auto_format.fmt_cmd
    (module struct
      let language_id = "bopkit-process"
      let extensions = [ ".bpp" ]
    end)
    (module Bopkit_process.Program)
    (module Bopkit_process_parser)
    (module Bopkit_process_pp.Program)
;;

let main =
  Command.group ~summary:"Bopkit Process File Tool" [ "exec", exec_cmd; "fmt", fmt_cmd ]
;;
