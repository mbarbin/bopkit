let () =
  Commandlang_to_cmdliner.run Bopkit_pulse.Pulse.main ~name:"pulse" ~version:"%%VERSION%%"
;;
