let main =
  Command.make
    ~summary:"check a bopkit project"
    (let%map_open.Command path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"file to check"
     and () = Err_cli.set_config ()
     and print_cds =
       Arg.flag [ "print-cds" ] ~doc:"print the cds out stdout in case of success"
     and bopkit_compiler_config = Bopkit_compiler.Config.arg in
     let circuit =
       Bopkit_compiler.circuit_of_netlist ~path ~config:bopkit_compiler_config
     in
     Err.info
       ~loc:circuit.main.loc
       [ Pp.textf "Check of '%s' complete." circuit.main.txt ];
     if print_cds then print_s [%sexp (circuit.cds : Bopkit_circuit.Cds.t)])
;;
