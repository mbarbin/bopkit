let parse_cmd =
  Command.make
    ~summary:"Parse and dump an assembly program ast."
    (let open Command.Std in
     let+ path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"Assembly program to process."
     and+ () = Log_cli.set_config () in
     let p = Parsing_utils.parse_file_exn (module Visa_parser) ~path in
     print_s [%sexp (p : Visa.Program.t)])
;;

let fmt_cmd =
  Auto_format.fmt_cmd
    (module struct
      let language_id = "visa-assembly"
      let extensions = [ ".asm" ]
    end)
    (module Visa.Program)
    (module Visa_parser)
    (module Visa_pp.Program)
;;

let process_cmd =
  Command.make
    ~summary:"Parse and print an assembly program after processing."
    (let open Command.Std in
     let+ path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"Assembly program to process."
     and+ () = Log_cli.set_config () in
     let program = Parsing_utils.parse_file_exn (module Visa_parser) ~path in
     let executable = Visa_assembler.program_to_executable ~program in
     let program = Visa.Executable.disassemble executable in
     print_string (Pp_extended.to_string (Visa_pp.Program.pp program)))
;;

let check_cmd =
  Command.make
    ~summary:"Parse and check an assembler program."
    (let open Command.Std in
     let+ path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"Assembly program to process."
     and+ () = Log_cli.set_config () in
     let program = Parsing_utils.parse_file_exn (module Visa_parser) ~path in
     let executable = Visa_assembler.program_to_executable ~program in
     let machine_code = Visa.Executable.to_machine_code executable in
     ignore (machine_code : Visa.Executable.Machine_code.t))
;;

let assemble_cmd =
  Command.make
    ~summary:"Parse and transform an assembler program into machine code."
    (let open Command.Std in
     let+ path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"Assembly program to process."
     and+ () = Log_cli.set_config () in
     let program = Parsing_utils.parse_file_exn (module Visa_parser) ~path in
     let executable = Visa_assembler.program_to_executable ~program in
     let machine_code = Visa.Executable.to_machine_code executable in
     print_string
       (Pp_extended.to_string (Visa_pp.Executable.Machine_code.pp machine_code)))
;;

let disassemble_cmd =
  Command.make
    ~summary:"Recreate an assembly program from machine code."
    (let open Command.Std in
     let+ path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"Machine code to process."
     and+ () = Log_cli.set_config () in
     let machine_code = Visa.Machine_code.of_text_file_exn ~path in
     let program = Visa.Executable.Machine_code.disassemble machine_code ~path in
     print_string (Pp_extended.to_string (Visa_pp.Program.pp program)))
;;

let main =
  Command.group
    ~summary:"Managing visa assembly programs."
    [ "assemble", assemble_cmd
    ; "check", check_cmd
    ; "digital-calendar", Seven_segment_display.Main.digital_calendar
    ; "disassemble", disassemble_cmd
    ; "fmt", fmt_cmd
    ; "parse", parse_cmd
    ; "process", process_cmd
    ; "run", Visa_simulator.main
    ]
;;
