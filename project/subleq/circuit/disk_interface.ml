open! Core

type t =
  { architecture : int
  ; debug : bool
  ; files_prefix : string
  ; number_of_programs : int
  ; mutable program_index : int
  }

let init ~architecture ~debug ~files_prefix ~number_of_programs =
  if debug
  then (
    Graphics.open_graph " 400x500";
    Graphics.set_window_title "Subleq Disk Interface");
  { architecture; debug; files_prefix; number_of_programs; program_index = 0 }
;;

exception End_of_execution

let next_ram (t : t) ~mem : unit =
  t.program_index <- succ t.program_index;
  let index_digits = String.length (Int.to_string t.number_of_programs) in
  let source_file = sprintf "%s%0*d.input" t.files_prefix index_digits t.program_index in
  if t.program_index >= 2
  then (
    let save_file =
      sprintf "%s%0*d.img" t.files_prefix index_digits (t.program_index - 1)
    in
    Printf.fprintf stderr "[ --> ] Saving RAM --> %S\n" save_file;
    Out_channel.flush stderr;
    Bopkit_memory.to_text_file mem ~filename:save_file);
  if t.program_index > t.number_of_programs then raise End_of_execution;
  Printf.fprintf stderr "[ <-- ] Loading RAM <-- %S\n" source_file;
  Out_channel.flush stderr;
  Bopkit_memory.load_text_file mem ~filename:source_file
;;

let main t =
  let width = t.architecture in
  let mem =
    Bopkit_memory.create ~name:"mem" ~address_width:width ~data_width:width ~kind:Ram ()
  in
  next_ram t ~mem;
  let was_standby = ref false in
  Bopkit_block.Method.main
    ~input_arity:(Tuple_4 (Bus { width }, Signal, Bus { width }, Signal))
    ~output_arity:(Bus { width })
    ~f:(fun ~input:(address, write, data_in, standby) ~output:data_out ->
      let reset = standby && not !was_standby in
      was_standby := standby;
      if reset
      then (
        Printf.fprintf stderr "RESET !!\n";
        Out_channel.flush stderr);
      Bopkit_memory.reset_all_color mem;
      if write
      then (
        Bopkit_memory.set_color
          mem
          ~address:(Bit_array.to_int address)
          ~color:Graphics.red;
        Bopkit_memory.write_bits mem ~address ~value:data_in)
      else (
        Bopkit_memory.set_color
          mem
          ~address:(Bit_array.to_int address)
          ~color:Graphics.green;
        Bopkit_memory.read_bits mem ~address ~dst:data_out);
      if t.debug then Bopkit_memory.draw mem;
      if reset then next_ram t ~mem)
;;

let () =
  Bopkit_block.run
    (let open Command.Let_syntax in
     let%map_open debug =
       flag "DEBUG" (optional_with_default 1 int) ~doc:" activate debug graphics"
       >>| Int.equal 1
     and architecture = flag "AR" (required int) ~doc:" architecture"
     and files_prefix =
       flag "files-prefix" (required string) ~doc:"PREF input files prefix"
     and number_of_programs =
       flag "num-programs" (required int) ~doc:"N number of programs to load"
     in
     let t = init ~architecture ~debug ~files_prefix ~number_of_programs in
     Bopkit_block.create ~name:"disk_interface" ~main:(main t) ())
;;
