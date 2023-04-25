open! Core

type t =
  { address_width : int
  ; data_width : int
  ; mem : Bopkit_memory.Ram.t
  }

let init ~title ~address_width ~data_width =
  Graphics.open_graph " 670x550+100-100";
  let title = Option.value title ~default:"RAM MEMORY" in
  Graphics.set_window_title title;
  let mem = Bopkit_memory.create ~name:"ram" ~address_width ~data_width ~kind:Ram () in
  let (_ : Core_thread.t) =
    Core_thread.create
      ~on_uncaught_exn:`Kill_whole_process
      (fun () -> Bopkit_memory.main_loop mem ~loop:true ())
      ()
  in
  Bopkit_memory.draw mem;
  { address_width; data_width; mem }
;;

let set_color_if_needed t ~needs_redraw ~address ~color =
  let is_needed =
    match Bopkit_memory.get_color t.mem ~address with
    | None -> true
    | Some previous_color -> Int.( <> ) previous_color color
  in
  if is_needed
  then (
    Bopkit_memory.set_color t.mem ~address ~color;
    needs_redraw := true)
;;

let write_if_needed t ~needs_redraw ~address ~data =
  let is_needed =
    let previous_data = Array.copy data in
    Bopkit_memory.read_bits t.mem ~address ~dst:previous_data;
    not (Bit_array.equal previous_data data)
  in
  if is_needed
  then (
    Bopkit_memory.write_bits t.mem ~address ~value:data;
    needs_redraw := true)
;;

let center_if_needed t ~needs_redraw ~on_address =
  match Bopkit_memory.center_view t.mem ~on_address with
  | `Not_needed_did_nothing -> ()
  | `Done_now_needs_to_redraw -> needs_redraw := true
;;

let main ({ address_width; data_width; mem } as t) =
  let last_set_color_address = ref None in
  let reset_last_address_color_if_needed ~needs_redraw ~address =
    let did_reset =
      match !last_set_color_address with
      | None -> false
      | Some last_address ->
        if last_address <> address
        then (
          Bopkit_memory.reset_color t.mem ~address:last_address;
          true)
        else false
    in
    last_set_color_address := Some address;
    if did_reset then needs_redraw := true
  in
  Bopkit_block.Method.main
    ~input_arity:
      (Tuple_4
         ( Bus { width = address_width }
         , Bus { width = address_width }
         , Signal
         , Bus { width = data_width } ))
    ~output_arity:(Bus { width = data_width })
    ~f:(fun ~input:(read_addr, write_addr, write_mode, data) ~output:w_out ->
      let needs_redraw = ref false in
      if write_mode
      then (
        center_if_needed t ~needs_redraw ~on_address:(Bit_array.to_int write_addr);
        reset_last_address_color_if_needed
          ~needs_redraw
          ~address:(Bit_array.to_int write_addr);
        set_color_if_needed
          t
          ~needs_redraw
          ~address:(Bit_array.to_int write_addr)
          ~color:Graphics.red;
        write_if_needed t ~needs_redraw ~address:write_addr ~data)
      else (
        center_if_needed t ~needs_redraw ~on_address:(Bit_array.to_int read_addr);
        reset_last_address_color_if_needed
          ~needs_redraw
          ~address:(Bit_array.to_int read_addr);
        set_color_if_needed
          t
          ~needs_redraw
          ~address:(Bit_array.to_int read_addr)
          ~color:Graphics.green;
        Bopkit_memory.read_bits mem ~address:read_addr ~dst:w_out);
      if !needs_redraw then Bopkit_memory.draw mem)
;;

let () =
  Bopkit_block.run
    (let open Command.Let_syntax in
     let%map_open address_width =
       flag
         "addresses-width"
         ~aliases:[ "addresses-len"; "a" ]
         (required int)
         ~doc:"N number of bit of addresses"
     and data_width =
       flag
         "words-width"
         ~aliases:[ "words-len"; "w" ]
         (required int)
         ~doc:"N number of bits of words"
     and title = flag "title" (optional string) ~doc:"TITLE set window title" in
     let t = init ~title ~address_width ~data_width in
     Bopkit_block.create ~name:"ram_memory" ~main:(main t) ~is_multi_threaded:true ())
;;
