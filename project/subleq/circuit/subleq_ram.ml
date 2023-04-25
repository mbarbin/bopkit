open! Core

type t =
  { architecture : int
  ; cl : int
  ; debug : bool
  }

let init ~architecture ~cl ~debug =
  if debug
  then (
    Graphics.open_graph " 400x500";
    Graphics.set_window_title "Subleq Internal RAM");
  { architecture; cl; debug }
;;

let reg_maker i =
  let t = Array.create ~len:i false in
  fun b bout ->
    (* We create [bin] in case [b==bout]. *)
    let bin = Array.copy b in
    Array.blit ~src:t ~src_pos:0 ~dst:bout ~dst_pos:0 ~len:i;
    Array.blit ~src:bin ~src_pos:0 ~dst:t ~dst_pos:0 ~len:i
;;

let main { architecture = ar; cl; debug } =
  let mem =
    Bopkit_memory.create ~name:"mem" ~address_width:ar ~data_width:ar ~kind:Ram ()
  in
  let regAR = reg_maker ar in
  let regS = reg_maker 1 in
  let sortie = Array.create ~len:ar false in
  let was_write = [| false |] in
  Bopkit_block.Method.main
    ~input_arity:
      (Tuple_5
         ( Bus { width = cl }
         , Bus { width = ar }
         , Signal
         , Bus { width = ar }
         , Bus { width = ar } ))
    ~output_arity:Empty
    ~f:(fun ~input:(step, mem_address, mem_write_mode, mem_data_in, reg_mem_out)
            ~output:() ->
      regS [| mem_write_mode |] was_write;
      let step = Bit_array.to_int step in
      if step = 0 then Bopkit_memory.reset_all_color mem;
      if mem_write_mode
      then (
        Bopkit_memory.set_color
          mem
          ~address:(Bit_array.to_int mem_address)
          ~color:Graphics.red;
        Bopkit_memory.write_bits mem ~address:mem_address ~value:mem_data_in;
        regAR sortie sortie)
      else (
        let col =
          let open Graphics in
          match step with
          | 0 -> green
          | 1 -> yellow
          | 2 -> green
          | 3 -> magenta
          | _ -> cyan
        in
        Bopkit_memory.set_color mem ~address:(Bit_array.to_int mem_address) ~color:col;
        Bopkit_memory.read_bits mem ~address:mem_address ~dst:sortie;
        regAR sortie sortie);
      if debug then Bopkit_memory.draw mem;
      if (not was_write.(0)) && not (Bit_array.equal reg_mem_out sortie)
      then
        Out_channel.prerr_endline
          (Sexp.to_string_hum
             [%sexp { expected = (sortie : bool array); reg_mem_out : bool array }]))
;;

let () =
  Bopkit_block.run
    (let open Command.Let_syntax in
     let%map_open debug =
       flag "DEBUG" (optional_with_default 1 int) ~doc:" activate debug graphics"
       >>| Int.equal 1
     and architecture = flag "AR" (required int) ~doc:" architecture"
     and cl = flag "CL" (required int) ~doc:" number of bits of cycle index" in
     let t = init ~architecture ~cl ~debug in
     Bopkit_block.create ~name:"subleq_ram" ~main:(main t) ())
;;
