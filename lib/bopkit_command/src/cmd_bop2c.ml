let main =
  Command.basic
    ~summary:"translate a bop project into a standalone C file"
    (let open Command.Let_syntax in
     let%map_open path = anon ("FILE" %: Fpath_extended.arg_type)
     and error_log_config = Error_log.Config.param
     and bopkit_compiler_config = Bopkit_compiler.Config.param in
     Error_log.report_and_exit ~config:error_log_config (fun error_log ->
       let open! Or_error.Let_syntax in
       let%bind circuit =
         Bopkit_compiler.circuit_of_netlist
           ~error_log
           ~path
           ~config:bopkit_compiler_config
       in
       Bopkit_to_c.emit_c_code ~circuit ~error_log ~to_:stdout;
       return ()))
;;
