module Sdl = Tsdl.Sdl

let v_NUMPUSH = 5
let v_NUMSWITCH = 8
let v_NUMLIGHT = 8
let v_WINWIDTH = 850
let v_WINHEIGHT = 300

module Size = struct
  type r =
    { x : int
    ; y : int
    }

  type t =
    { sizepush : r
    ; sizeswitch : r
    ; sizelight : r
    }

  let create () =
    { sizepush = { x = 100; y = 50 }
    ; sizeswitch = { x = 50; y = 100 }
    ; sizelight = { x = 100; y = 100 }
    }
  ;;
end

module Plate = struct
  type t =
    { x : int
    ; y : int
    ; img : Sdl.surface
    }
end

module Button = struct
  type img =
    { img_active : Sdl.surface
    ; img_unactive : Sdl.surface
    }

  type t =
    { pos : Size.r
    ; size : Size.r
    ; mutable active : bool
    ; img : img
    }

  let contains_coordinates t ~x ~y =
    x > t.pos.x && x < t.pos.x + t.size.x && y > t.pos.y && y < t.pos.y + t.size.y
  ;;

  let find buttons ~x ~y =
    Array.find buttons ~f:(fun button -> contains_coordinates button ~x ~y)
  ;;
end

module Board = struct
  type t =
    { size : Size.t
    ; plates : Plate.t array
    ; pushes : Button.t array
    ; switches : Button.t array
    ; lights : Button.t array
    ; all_buttons : Button.t array
    }
  [@@deriving fields]
end

let find_image ~image =
  let ( ^/ ) = Stdlib.Filename.concat in
  List.find_map Bopkit_sites.Sites.bopboard ~f:(fun bopboard_directory ->
    let file = bopboard_directory ^/ "images" ^/ Image.basename image in
    if Stdlib.Sys.file_exists file then Some file else None)
;;

let result_exn = function
  | Ok s -> s
  | Error (`Msg s) ->
    let error = Sdl.get_error () in
    raise_s [%sexp "result_exn", Msg (s : string), { error : string }]
;;

let load_img image =
  Tsdl_image.Image.load (find_image ~image |> Option.value_exn ~here:[%here])
  |> result_exn
;;

let init_plates ~(size : Size.t) =
  let light_x = 10 in
  let q : Plate.t Queue.t = Queue.create () in
  let add_plate p = Queue.enqueue q p in
  add_plate { x = 0 + light_x; y = 5; img = load_img Ladybgleft };
  for i = 1 to 6 do
    add_plate { x = 12 + (i * 100) + light_x; y = 5; img = load_img Ladybgmid }
  done;
  add_plate { x = 12 + (100 * 7) + light_x; y = 5; img = load_img Ladybgright };
  add_plate { x = 0; y = v_WINHEIGHT - 70; img = load_img Pushbg };
  add_plate
    { x = 120 + ((size.sizepush.x + 20) * 5)
    ; y = v_WINHEIGHT - 70
    ; img = load_img Pushbg
    };
  add_plate
    { x = 120 + ((size.sizepush.x + 20) * 6)
    ; y = v_WINHEIGHT - 70
    ; img = load_img Pushbg
    };
  add_plate { x = 0; y = 125; img = load_img Switchbg };
  add_plate { x = 200 + (53 * 8); y = 125; img = load_img Switchbg };
  Queue.to_array q
;;

let init_pushes ~(size : Size.t) =
  let q : Button.t Queue.t = Queue.create () in
  let add_button p = Queue.enqueue q p in
  let imgpush =
    Button.{ img_active = load_img Pushdown; img_unactive = load_img Pushup }
  in
  for i = 0 to v_NUMPUSH - 1 do
    add_button
      { pos = { x = 120 + ((size.sizepush.x + 20) * i); y = v_WINHEIGHT - 70 }
      ; size = size.sizepush
      ; active = false
      ; img = imgpush
      }
  done;
  Queue.to_array q
;;

let init_switches ~(size : Size.t) =
  let q : Button.t Queue.t = Queue.create () in
  let add_button p = Queue.enqueue q p in
  let imgswitch =
    Button.{ img_active = load_img Switchup; img_unactive = load_img Switchdown }
  in
  for i = 0 to v_NUMSWITCH - 1 do
    add_button
      { pos = { x = 210 + (53 * i); y = 125 }
      ; size = size.sizeswitch
      ; active = false
      ; img = imgswitch
      }
  done;
  Queue.to_array q
;;

let init_lights ~(size : Size.t) =
  let q : Button.t Queue.t = Queue.create () in
  let add_button p = Queue.enqueue q p in
  let imglight =
    Button.{ img_active = load_img Ladyon; img_unactive = load_img Ladyoff }
  in
  for i = 0 to v_NUMLIGHT - 1 do
    add_button
      { pos = { x = 20 + (size.sizelight.x * i); y = 10 }
      ; size = size.sizelight
      ; active = false
      ; img = imglight
      }
  done;
  Queue.to_array q
;;

let init_board () =
  let size = Size.create () in
  let pushes = init_pushes ~size in
  let switches = init_switches ~size in
  let lights = init_lights ~size in
  let all_buttons = Array.concat [ pushes; switches; lights ] in
  { Board.size; plates = init_plates ~size; pushes; switches; lights; all_buttons }
;;

type t =
  { window : Sdl.window
  ; screen : Sdl.surface
  ; renderer : Sdl.renderer
  ; mutable previous_texture : Sdl.texture option
  ; board : Board.t
  }

let init ~title =
  let board = init_board () in
  Sdl.init Sdl.Init.(video + events) |> result_exn;
  let window =
    Sdl.create_window title ~w:v_WINWIDTH ~h:v_WINHEIGHT Sdl.Window.opengl |> result_exn
  in
  Sdl.set_window_icon window (load_img Ladyon);
  let screen = Sdl.get_window_surface window |> result_exn in
  let renderer = Sdl.create_renderer window |> result_exn in
  { window; screen; renderer; previous_texture = None; board }
;;

let draw_interface screen ~(board : Board.t) =
  let () =
    let format = Sdl.get_surface_format_enum screen |> Sdl.alloc_format |> result_exn in
    Sdl.fill_rect screen None (Sdl.map_rgb format 28 28 69) |> result_exn;
    Sdl.free_format format
  in
  Array.iter board.plates ~f:(fun plate ->
    let rect = Sdl.Rect.create ~x:plate.x ~y:plate.y ~w:0 ~h:0 in
    Sdl.blit_surface ~src:plate.img None ~dst:screen (Some rect) |> result_exn);
  let blit_button (button : Button.t) =
    let rect = Sdl.Rect.create ~x:button.pos.x ~y:button.pos.y ~w:0 ~h:0 in
    Sdl.blit_surface
      ~src:(if button.active then button.img.img_active else button.img.img_unactive)
      None
      ~dst:screen
      (Some rect)
    |> result_exn
  in
  Array.iter board.all_buttons ~f:blit_button
;;

let redraw (t : t) =
  draw_interface t.screen ~board:t.board;
  Sdl.render_clear t.renderer |> result_exn;
  let texture = Sdl.create_texture_from_surface t.renderer t.screen |> result_exn in
  Option.iter t.previous_texture ~f:Sdl.destroy_texture;
  t.previous_texture <- Some texture;
  Sdl.render_copy t.renderer texture |> result_exn;
  Sdl.render_present t.renderer
;;

let destroy_and_quit (t : t) =
  Sdl.destroy_renderer t.renderer;
  Sdl.destroy_window t.window;
  Sdl.quit ();
  Stdlib.exit 0
;;

let stress_test (t : t) =
  let event = Sdl.Event.create () in
  With_return.with_return (fun return ->
    while true do
      redraw t;
      let () =
        ignore (Sdl.wait_event_timeout (Some event) 5 : bool);
        match Sdl.Event.(enum (get event typ)) with
        | `Quit -> return.return ()
        | _ -> ()
      in
      match Random.int 3 with
      | 0 ->
        let i = Random.int (Array.length t.board.lights) in
        t.board.lights.(i).active <- not t.board.lights.(i).active
      | 1 ->
        let i = Random.int (Array.length t.board.switches) in
        t.board.switches.(i).active <- not t.board.switches.(i).active
      | _ ->
        let i = Random.int (Array.length t.board.pushes) in
        t.board.pushes.(i).active <- not t.board.pushes.(i).active
    done)
;;

let event_loop (t : t) =
  let event = Sdl.Event.create () in
  let needs_redraw = ref true in
  With_return.with_return (fun return ->
    while true do
      if !needs_redraw
      then (
        needs_redraw := false;
        redraw t);
      match Sdl.wait_event (Some event) with
      | Error (`Msg e) -> Stdlib.Printf.eprintf "wait event error %S\n%!" e
      | Ok () ->
        (match Sdl.Event.(enum (get event typ)) with
         | `Quit -> return.return ()
         | `Key_down ->
           let keycode = Sdl.Event.get event Sdl.Event.keyboard_keycode in
           if keycode = Sdl.K.escape then return.return ()
         | `Mouse_button_down ->
           let x = Sdl.Event.get event Sdl.Event.mouse_button_x in
           let y = Sdl.Event.get event Sdl.Event.mouse_button_y in
           (match Button.find t.board.pushes ~x ~y with
            | None -> ()
            | Some button ->
              needs_redraw := true;
              button.active <- true);
           (match Button.find t.board.switches ~x ~y with
            | None -> ()
            | Some button ->
              needs_redraw := true;
              button.active <- not button.active)
         | `Mouse_button_up ->
           Array.iter t.board.pushes ~f:(fun button ->
             if button.active
             then (
               needs_redraw := true;
               button.active <- false))
         | _ -> ())
    done);
  destroy_and_quit t
;;

let light_method (t : t) =
  (* This method has a variable input length depending on how it is called. If
     it has an argument, we expect it to be the index of a single light,
     otherwise it should be empty in which case we set the entire light array.
  *)
  Bopkit_block.Method.create
    ~name:"light"
    ~input_arity:Remaining_bits
    ~output_arity:Empty
    ~f:(fun ~arguments ~input ~output:() ->
      let needs_redraw = ref false in
      let set_light (light : Button.t) active =
        if Bool.( <> ) light.active active
        then (
          needs_redraw := true;
          light.active <- active)
      in
      (match arguments with
       | _ :: _ :: _ ->
         raise_s [%sexp "invalid arguments", [%here], { arguments : string list }]
       | [] ->
         let expected_length = Array.length t.board.lights in
         let input_length = Array.length input in
         if input_length <> expected_length
         then
           raise_s
             [%sexp
               "unexpected input length"
             , [%here]
             , { expected_length : int; input_length : int }];
         Array.iter2_exn t.board.lights input ~f:set_light
       | [ index ] ->
         let index = Int.of_string index in
         if index < 0 || index >= Array.length t.board.lights
         then raise_s [%sexp "light index out of bounds", [%here], { index : int }];
         let input_length = Array.length input in
         let expected_length = 1 in
         if input_length <> expected_length
         then
           raise_s
             [%sexp
               "unexpected input length"
             , [%here]
             , { expected_length : int; input_length : int }];
         set_light t.board.lights.(index) input.(0));
      if !needs_redraw then redraw t)
;;

let button_method (t : t) ~name ~which_buttons =
  (* This method has a variable output length depending on how it is called. If
     it has an argument, we expect it to be the index of a single button,
     otherwise it should be empty in which case we return the entire button
     array. *)
  Bopkit_block.Method.create
    ~name
    ~input_arity:Empty
    ~output_arity:Output_buffer
    ~f:(fun ~arguments ~input:() ~output ->
      let output_button (button : Button.t) =
        Buffer.add_char output (if button.active then '1' else '0')
      in
      let buttons = which_buttons t.board in
      match arguments with
      | [] -> Array.iter buttons ~f:output_button
      | [ index ] ->
        let index = Int.of_string index in
        if index < 0 || index >= Array.length buttons
        then
          raise_s
            [%sexp "button index out of bounds", [%here], { name : string; index : int }];
        output_button buttons.(index)
      | _ :: _ :: _ ->
        raise_s [%sexp "invalid arguments", [%here], { arguments : string list }])
;;

let main_method (_ : t) =
  Bopkit_block.Method.main
    ~input_arity:Empty
    ~output_arity:Empty
    ~f:(fun ~input:() ~output:() -> ())
;;

let run_cmd =
  Bopkit_block.main
    (let%map_open.Command title =
       Arg.named_with_default
         [ "title" ]
         Param.string
         ~default:"bopboard"
         ~docv:"TITLE"
         ~doc:"Set window title."
     in
     let t = init ~title in
     let (_ : Thread.t) =
       Thread.create
         (fun () ->
            match event_loop t with
            | () -> ()
            | exception e ->
              prerr_endline (Exn.to_string e);
              Stdlib.exit 1)
         ()
     in
     Bopkit_block.create
       ~name:"bopboard"
       ~main:(main_method t)
       ~methods:
         [ light_method t
         ; button_method t ~name:"push" ~which_buttons:Board.pushes
         ; button_method t ~name:"switch" ~which_buttons:Board.switches
         ]
       ~is_multi_threaded:true
       ())
;;

let stress_test_cmd =
  Command.make
    ~summary:"A stress test for the bopboard."
    (let%map_open.Command () = Arg.return () in
     let t = init ~title:"Bopboard Stress Test" in
     stress_test t;
     destroy_and_quit t)
;;

let main =
  Command.group
    ~summary:"Bopkit Bopboard"
    [ "check-images", Cmd_check_images.main
    ; "run", run_cmd
    ; "stress-test", stress_test_cmd
    ]
;;
