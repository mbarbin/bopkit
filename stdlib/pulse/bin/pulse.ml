let () =
  Cmdlang_cmdliner_runner.run Bopkit_pulse.Pulse.main ~name:"pulse" ~version:"%%VERSION%%"
;;
