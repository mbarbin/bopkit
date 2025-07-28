let main =
  Command.group
    ~summary:"Bopkit Binary Decision Diagram Tool."
    [ "checker", Cmd_checker.main
    ; "synthesize", Cmd_synthesize.main
    ; "bomber", Cmd_bomber.main
    ]
;;
