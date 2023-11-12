let main =
  Command.basic
    ~summary:"check a bopkit project"
    (let open Command.Let_syntax in
     let%map_open path = anon ("FILE" %: Fpath_extended.arg_type)
     and error_log_config = Error_log.Config.param
     and print_cds =
       flag "print-cds" no_arg ~doc:" print the cds out stdout in case of success"
     and bopkit_compiler_config = Bopkit_compiler.Config.param in
     Error_log.report_and_exit ~config:error_log_config (fun error_log ->
       let open! Or_error.Let_syntax in
       let%bind circuit =
         Bopkit_compiler.circuit_of_netlist
           ~error_log
           ~path
           ~config:bopkit_compiler_config
       in
       Error_log.info
         error_log
         [ Pp.textf "Check of %S complete." (circuit.path |> Fpath.to_string) ];
       if print_cds then print_s [%sexp (circuit.cds : Bopkit_circuit.Cds.t)];
       return ()))
;;
