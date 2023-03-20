open! Core
module Config = Config

exception SigInt

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
    Circuit_simulator.one_cycle circuit_simulator ~blit_input:(fun ~dst ->
      Input_handler.blit_input input_handler ~dst ~error_log);
    Output_handler.output
      output_handler
      ~input:(Circuit_simulator.input circuit_simulator)
      ~output:(Circuit_simulator.output circuit_simulator)
  in
  (* Make it possible to interupt the simulation on sigint. *)
  Caml.(Sys.set_signal Sys.sigint (Sys.Signal_handle (fun _ -> raise SigInt)));
  (try
     match num_cycles with
     | None ->
       while true do
         one_cycle ()
       done
     | Some nb_cycles ->
       for _ = 1 to nb_cycles do
         one_cycle ()
       done
   with
   | SigInt -> ()
   | End_of_file -> ());
  Error_log.info error_log [ Pp.textf "End of simulation (%S)" circuit.filename ];
  Circuit_simulator.quit circuit_simulator
;;
