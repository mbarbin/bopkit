open! Core

let generate_cmd =
  Command.basic
    ~summary:"generate subleq images for testing"
    (let open Command.Let_syntax in
     let%map_open architecture = flag "architecture" (required int) ~doc:"N architecture"
     and with_cycle = flag "with-cycle" no_arg ~doc:" generate programs with cycles"
     and generated_files_prefix =
       flag
         "generated-files-prefix"
         (required string)
         ~doc:"pref prefix for generated files"
     and number_of_programs =
       flag "num-programs" (required int) ~doc:"N number of programs to generate"
     in
     fun () ->
       Random.self_init ();
       let subleq_generator =
         Subleq_generator.create
           ~architecture
           ~with_cycle
           ~number_of_programs
           ~generated_files_prefix
       in
       Subleq_generator.generate_all subleq_generator)
;;

let simulate_cmd =
  Command.basic
    ~summary:"generate subleq images for testing"
    (let open Command.Let_syntax in
     let%map_open debugger = flag "g" no_arg ~doc:" run a graphic debugger"
     and architecture =
       flag "ar" (optional_with_default 4 int) ~doc:"N architecture (default 4)"
     and filename = anon ("FILE" %: string) in
     fun () ->
       let initial_memory =
         Bit_matrix.of_text_file
           ~dimx:(Int.pow 2 architecture)
           ~dimy:architecture
           ~filename
       in
       if debugger
       then (
         let subleq_debugger = Subleq_debugger.create_exn initial_memory in
         Graphics.open_graph " 300x400";
         Graphics.set_window_title "Subleq Debugger";
         Subleq_debugger.run subleq_debugger)
       else (
         let subleq_simulator = Subleq_simulator.create ~architecture in
         Subleq_simulator.reset_exn subleq_simulator initial_memory;
         match Subleq_simulator.run subleq_simulator with
         | Program_does_not_terminate ->
           prerr_endline "Program does not terminate";
           exit 1
         | Success -> Subleq_simulator.print_memory subleq_simulator ~out_channel:stdout))
;;

let main =
  Command.group
    ~summary:"subleq simulator"
    ~readme:(fun () ->
      {|
This program allows to simulate the execution of a subleq machine on input programs.

It provides a simulator, a step-by-step debugger, and a program generator which may
be used to create some input programs which do not loop.
|})
    [ "generate", generate_cmd; "simulate", simulate_cmd ]
;;
