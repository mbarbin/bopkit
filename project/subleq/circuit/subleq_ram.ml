type t =
  { architecture : int
  ; cl : int
  ; debug : bool
  ; mem : Bopkit_memory.Ram.t
  }

let init ~architecture ~cl ~debug =
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
    Graphics.open_graph " 400x500";
    Graphics.set_window_title "Subleq Internal RAM";
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
  { architecture; cl; debug; mem }
;;

let reg_maker i =
  let t = Array.create ~len:i false in
  fun b bout ->
    (* We create [bin] in case [b==bout]. *)
    let bin = Array.copy b in
    Array.blit ~src:t ~src_pos:0 ~dst:bout ~dst_pos:0 ~len:i;
    Array.blit ~src:bin ~src_pos:0 ~dst:t ~dst_pos:0 ~len:i
;;

let main { architecture = ar; cl; debug; mem } =
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
    ~f:
      (fun
        ~input:(step, mem_address, mem_write_mode, mem_data_in, reg_mem_out) ~output:() ->
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
    (let open Command.Std in
     let+ debug =
       Arg.named_with_default
         [ "DEBUG" ]
         Param.int
         ~default:1
         ~doc:"Activate debug graphics when equal to $(b,1)."
       >>| Int.equal 1
     and+ architecture =
       Arg.named [ "AR" ] Param.int ~doc:"The size of the architecture parameter."
     and+ cl = Arg.named [ "CL" ] Param.int ~doc:"Number of bits of cycle index." in
     let t = init ~architecture ~cl ~debug in
     Bopkit_block.create ~name:"subleq_ram" ~main:(main t) ())
;;
