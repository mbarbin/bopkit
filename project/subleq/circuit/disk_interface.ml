type t =
  { architecture : int
  ; debug : bool
  ; files_prefix : string
  ; number_of_programs : int
  ; mutable program_index : int
  ; mem : Bopkit_memory.Ram.t
  }

let init ~architecture ~debug ~files_prefix ~number_of_programs =
  if debug
  then (
    Graphics.open_graph " 400x500";
    Graphics.set_window_title "Subleq Disk Interface");
  let mem =
    Bopkit_memory.create
      ~name:"mem"
      ~address_width:architecture
      ~data_width:architecture
      ~kind:Ram
      ()
  in
  if debug
  then (
    let (_ : Thread.t) =
      Thread.create
        (fun () ->
           (match Bopkit_memory.event_loop mem ~read_only:true with
            | () -> 0
            | exception e ->
              prerr_endline (Exn.to_string e);
              1)
           |> Stdlib.exit)
        ()
    in
    Bopkit_memory.draw mem);
  { architecture; debug; files_prefix; number_of_programs; program_index = 0; mem }
;;

let next_ram (t : t) : unit =
  t.program_index <- Int.succ t.program_index;
  let index_digits = String.length (Int.to_string t.number_of_programs) in
  let source_file =
    Printf.sprintf "%s%0*d.input" t.files_prefix index_digits t.program_index |> Fpath.v
  in
  if t.program_index >= 2
  then (
    let save_file =
      Printf.sprintf "%s%0*d.img" t.files_prefix index_digits (t.program_index - 1)
      |> Fpath.v
    in
    Stdlib.Printf.fprintf
      stderr
      "[ --> ] Saving RAM --> %S\n"
      (save_file |> Fpath.to_string);
    Out_channel.flush stderr;
    Bopkit_memory.to_text_file t.mem ~path:save_file);
  if t.program_index > t.number_of_programs then Stdlib.exit 0;
  Stdlib.Printf.fprintf
    stderr
    "[ <-- ] Loading RAM <-- %S\n"
    (source_file |> Fpath.to_string);
  Out_channel.flush stderr;
  Bopkit_memory.load_text_file t.mem ~path:source_file
;;

let main t =
  let width = t.architecture in
  next_ram t;
  let was_standby = ref false in
  Bopkit_block.Method.main
    ~input_arity:(Tuple_4 (Bus { width }, Signal, Bus { width }, Signal))
    ~output_arity:(Bus { width })
    ~f:(fun ~input:(address, write, data_in, standby) ~output:data_out ->
      let reset = standby && not !was_standby in
      was_standby := standby;
      if reset
      then (
        Stdlib.Printf.fprintf stderr "RESET !!\n";
        Out_channel.flush stderr);
      Bopkit_memory.reset_all_color t.mem;
      if write
      then (
        Bopkit_memory.set_color
          t.mem
          ~address:(Bit_array.to_int address)
          ~color:Graphics.red;
        Bopkit_memory.write_bits t.mem ~address ~value:data_in)
      else (
        Bopkit_memory.set_color
          t.mem
          ~address:(Bit_array.to_int address)
          ~color:Graphics.green;
        Bopkit_memory.read_bits t.mem ~address ~dst:data_out);
      if t.debug then Bopkit_memory.draw t.mem;
      if reset then next_ram t)
;;

let () =
  Bopkit_block.run
    (let%map_open.Command debug =
       Arg.named_with_default
         [ "DEBUG" ]
         Param.int
         ~default:1
         ~doc:"activate debug graphics"
       >>| Int.equal 1
     and architecture = Arg.named [ "AR" ] Param.int ~doc:"architecture"
     and files_prefix =
       Arg.named [ "files-prefix" ] Param.string ~docv:"PREF" ~doc:"input files prefix"
     and number_of_programs =
       Arg.named [ "num-programs" ] Param.int ~docv:"N" ~doc:"number of programs to load"
     in
     let t = init ~architecture ~debug ~files_prefix ~number_of_programs in
     Bopkit_block.create ~name:"disk_interface" ~main:(main t) ())
;;
