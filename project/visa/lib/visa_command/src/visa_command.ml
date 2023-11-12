let parse_cmd =
  Command.basic
    ~summary:"parse and dump an assembler program ast"
    (let open Command.Let_syntax in
     let%map_open path = anon ("FILE" %: Fpath_extended.arg_type)
     and config = Error_log.Config.param in
     Error_log.report_and_exit ~config (fun error_log ->
       let open Or_error.Let_syntax in
       let p = Parsing_utils.parse_file_exn (module Visa_syntax) ~path ~error_log in
       print_s [%sexp (p : Visa.Program.t)];
       return ()))
;;

let fmt_cmd =
  Auto_format.fmt_cmd
    (module struct
      let language_id = "visa-assembly"
      let extensions = [ ".asm" ]
    end)
    (module Visa.Program)
    (module Visa_syntax)
    (module Visa_pp.Program)
;;

let process_cmd =
  Command.basic
    ~summary:"parse and print an assembler program after processing"
    (let open Command.Let_syntax in
     let%map_open path = anon ("FILE" %: Fpath_extended.arg_type)
     and config = Error_log.Config.param in
     Error_log.report_and_exit ~config (fun error_log ->
       let open Or_error.Let_syntax in
       let program = Parsing_utils.parse_file_exn (module Visa_syntax) ~path ~error_log in
       let%bind executable = Visa_assembler.program_to_executable ~error_log ~program in
       let program = Visa.Executable.disassemble executable in
       Format.printf "%a%!" Pp.to_fmt (Visa_pp.Program.pp program);
       return ()))
;;

let check_cmd =
  Command.basic
    ~summary:"parse and check an assembler program"
    (let open Command.Let_syntax in
     let%map_open path = anon ("FILE" %: Fpath_extended.arg_type)
     and config = Error_log.Config.param in
     Error_log.report_and_exit ~config (fun error_log ->
       let open Or_error.Let_syntax in
       let program = Parsing_utils.parse_file_exn (module Visa_syntax) ~path ~error_log in
       let%bind executable = Visa_assembler.program_to_executable ~error_log ~program in
       let machine_code = Visa.Executable.to_machine_code executable in
       ignore (machine_code : Visa.Executable.Machine_code.t);
       return ()))
;;

let assemble_cmd =
  Command.basic
    ~summary:"parse and transform an assembler program into machine code"
    (let open Command.Let_syntax in
     let%map_open path = anon ("FILE" %: Fpath_extended.arg_type)
     and config = Error_log.Config.param in
     Error_log.report_and_exit ~config (fun error_log ->
       let open Or_error.Let_syntax in
       let program = Parsing_utils.parse_file_exn (module Visa_syntax) ~path ~error_log in
       let%bind executable = Visa_assembler.program_to_executable ~error_log ~program in
       let machine_code = Visa.Executable.to_machine_code executable in
       Format.printf "%a%!" Pp.to_fmt (Visa_pp.Executable.Machine_code.pp machine_code);
       return ()))
;;

let disassemble_cmd =
  Command.basic
    ~summary:"recreate an assembler program from machine code"
    (let open Command.Let_syntax in
     let%map_open path = anon ("FILE" %: Fpath_extended.arg_type)
     and config = Error_log.Config.param in
     Error_log.report_and_exit ~config (fun error_log ->
       let open Or_error.Let_syntax in
       let machine_code = Visa.Machine_code.of_text_file_exn ~path ~error_log in
       let program =
         Visa.Executable.Machine_code.disassemble machine_code ~path ~error_log
       in
       Format.printf "%a%!" Pp.to_fmt (Visa_pp.Program.pp program);
       return ()))
;;

let main =
  Command.group
    ~summary:"visa assembler"
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
