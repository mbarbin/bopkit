module Config = Config

let run ~circuit ~error_log ~config =
  let circuit_simulator = Circuit_simulator.of_circuit ~circuit ~error_log in
  let expected_input_length = Array.length (Circuit_simulator.input circuit_simulator) in
  let output_handler =
    Output_handler.create
      ~config
      ~input_names:circuit.input_names
      ~output_names:circuit.output_names
  in
  let input_handler = Input_handler.create ~config ~expected_input_length in
  let num_cycles = Config.num_cycles config ~expected_input_length in
  Error_log.info
    error_log
    [ (match num_cycles with
       | None -> Pp.text "Starting simulation."
       | Some cycles -> Pp.textf "Starting simulation for %d cycles" cycles)
    ];
  Circuit_simulator.init circuit_simulator;
  Output_handler.init output_handler;
  Error_log.flush error_log;
  let one_cycle () =
    Circuit_simulator.one_cycle
      circuit_simulator
      ~blit_input:(fun ~dst -> Input_handler.blit_input input_handler ~dst ~error_log)
      ~output_handler:(fun ~input ~output ->
        Output_handler.output output_handler ~input ~output)
  in
  (* Make it possible to interrupt the simulation on sigint. *)
  Sys_unix.catch_break true;
  (try
     with_return (fun { return } ->
       match num_cycles with
       | None ->
         while true do
           match one_cycle () with
           | Continue -> ()
           | Quit -> return ()
         done
       | Some nb_cycles ->
         for _ = 1 to nb_cycles do
           match one_cycle () with
           | Continue -> ()
           | Quit -> return ()
         done)
   with
   | Sys_unix.Break | End_of_file -> ());
  Error_log.info error_log [ Pp.textf "End of simulation (%S)" circuit.filename ];
  Circuit_simulator.quit circuit_simulator
;;
