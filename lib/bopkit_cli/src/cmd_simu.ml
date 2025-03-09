let main =
  Command.make
    ~summary:"simulate the execution of a bopkit project"
    (let%map_open.Command path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"file to simulate"
     and () = Log_cli.set_config ()
     and bopkit_compiler_config = Bopkit_compiler.Config.arg
     and bopkit_simulator_config = Bopkit_simulator.Config.arg in
     let circuit =
       Bopkit_compiler.circuit_of_netlist ~path ~config:bopkit_compiler_config
     in
     Bopkit_simulator.run ~circuit ~config:bopkit_simulator_config)
;;
