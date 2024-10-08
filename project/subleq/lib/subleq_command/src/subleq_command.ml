let generate_cmd =
  Command.make
    ~summary:"generate subleq images for testing"
    (let%map_open.Command architecture =
       Arg.named [ "architecture" ] Param.int ~docv:"N" ~doc:"architecture"
     and with_cycle = Arg.flag [ "with-cycle" ] ~doc:"generate programs with cycles"
     and generated_files_prefix =
       Arg.named
         [ "generated-files-prefix" ]
         Param.string
         ~docv:"PREF"
         ~doc:"prefix for generated files"
     and number_of_programs =
       Arg.named
         [ "num-programs" ]
         Param.int
         ~docv:"N"
         ~doc:"number of programs to generate"
     in
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
  Command.make
    ~summary:"simulate execution of subleq image"
    (let%map_open.Command debugger = Arg.flag [ "g" ] ~doc:"run a graphic debugger"
     and architecture =
       Arg.named_with_default
         [ "ar" ]
         Param.int
         ~default:4
         ~docv:"N"
         ~doc:"architecture (default 4)"
     and path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"file to execute"
     in
     let initial_memory =
       Bit_matrix.of_text_file ~dimx:(Int.pow 2 architecture) ~dimy:architecture ~path
     in
     if debugger
     then (
       let subleq_debugger = Subleq_debugger.create_exn initial_memory in
       Subleq_debugger.run subleq_debugger)
     else (
       let subleq_simulator = Subleq_simulator.create ~architecture in
       Subleq_simulator.reset_exn subleq_simulator initial_memory;
       match Subleq_simulator.run subleq_simulator with
       | Program_does_not_terminate ->
         prerr_endline "Program does not terminate";
         Stdlib.exit 1
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
