let () =
  Cmdlang_cmdliner_runner.run Bopkit_command.main ~name:"bopkit" ~version:"%%VERSION%%"
;;
