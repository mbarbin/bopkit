(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Sdl = Tsdl.Sdl

let v_NUMPUSH = 5
let v_NUMSWITCH = 8
let v_NUMLIGHT = 8
let v_WINWIDTH = 850
let v_WINHEIGHT = 300

let create_board_state () =
  Board_state.create
    ~num_lights:v_NUMLIGHT
    ~num_switches:v_NUMSWITCH
    ~num_pushes:v_NUMPUSH
;;

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
    ; sizeswitch = { x = 53; y = 100 }
    ; sizelight = { x = 100; y = 100 }
    }
  ;;
end

module Plate = struct
  type t =
    { x : int
    ; y : int
    ; img : Sdl.texture
    }
end

module Shared_bit = struct
  (* This module allows sharing mutable state with [Board_state]. *)
  type t =
    | T of
        { bits : bool array
        ; index : int
        }

  let get (T { bits; index }) = bits.(index)
end

module Button = struct
  type img =
    { img_active : Sdl.texture
    ; img_inactive : Sdl.texture
    }

  type size =
    { size_active : Size.r
    ; size_inactive : Size.r
    }

  type t =
    { pos : Size.r
    ; size : size
    ; state : Shared_bit.t
    ; img : img
    }

  let is_active t = Shared_bit.get t.state

  let contains_coordinates t ~x ~y =
    let size = if is_active t then t.size.size_active else t.size.size_inactive in
    x > t.pos.x && x < t.pos.x + size.x && y > t.pos.y && y < t.pos.y + size.y
  ;;

  let find buttons ~x ~y =
    Array.find buttons ~f:(fun button -> contains_coordinates button ~x ~y)
  ;;
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

(* Load an image as an SDL surface. *)
let load_surface ~image =
  Tsdl_image.Image.load (find_image ~image |> Option.value_exn ~here:[%here])
  |> result_exn
;;

(* Load an image directly as an SDL texture (more efficient for rendering). *)
let load_texture ~renderer ~image =
  let surface = load_surface ~image in
  let texture = Sdl.create_texture_from_surface renderer surface |> result_exn in
  Sdl.free_surface surface;
  texture
;;

let init_plates ~renderer ~(size : Size.t) =
  let light_x = 10 in
  let q : Plate.t Queue.t = Queue.create () in
  let add_plate p = Queue.enqueue q p in
  add_plate { x = 0 + light_x; y = 5; img = load_texture ~renderer ~image:Ladybgleft };
  for i = 1 to 6 do
    add_plate
      { x = 12 + (i * 100) + light_x
      ; y = 5
      ; img = load_texture ~renderer ~image:Ladybgmid
      }
  done;
  add_plate
    { x = 12 + (100 * 7) + light_x
    ; y = 5
    ; img = load_texture ~renderer ~image:Ladybgright
    };
  add_plate { x = 0; y = v_WINHEIGHT - 70; img = load_texture ~renderer ~image:Pushbg };
  add_plate
    { x = 120 + ((size.sizepush.x + 20) * 5)
    ; y = v_WINHEIGHT - 70
    ; img = load_texture ~renderer ~image:Pushbg
    };
  add_plate
    { x = 120 + ((size.sizepush.x + 20) * 6)
    ; y = v_WINHEIGHT - 70
    ; img = load_texture ~renderer ~image:Pushbg
    };
  add_plate { x = 0; y = 125; img = load_texture ~renderer ~image:Switchbg };
  add_plate
    { x = 200 + (size.sizeswitch.x * 8)
    ; y = 125
    ; img = load_texture ~renderer ~image:Switchbg
    };
  Queue.to_array q
;;

let texture_size texture =
  let _, _, (x, y) = Sdl.query_texture texture |> result_exn in
  { Size.x; y }
;;

let button_size (img : Button.img) : Button.size =
  { size_active = texture_size img.img_active
  ; size_inactive = texture_size img.img_inactive
  }
;;

let init_pushes ~board_state ~renderer ~(size : Size.t) =
  let img : Button.img =
    { img_active = load_texture ~renderer ~image:Pushdown
    ; img_inactive = load_texture ~renderer ~image:Pushup
    }
  in
  let bits = Board_state.pushes board_state in
  Array.init v_NUMPUSH ~f:(fun i ->
    { Button.pos = { x = 120 + ((size.sizepush.x + 20) * i); y = v_WINHEIGHT - 70 }
    ; size = button_size img
    ; state = Shared_bit.T { bits; index = i }
    ; img
    })
;;

let init_switches ~board_state ~renderer ~(size : Size.t) =
  let img : Button.img =
    { img_active = load_texture ~renderer ~image:Switchup
    ; img_inactive = load_texture ~renderer ~image:Switchdown
    }
  in
  let bits = Board_state.switches board_state in
  Array.init v_NUMSWITCH ~f:(fun i ->
    { Button.pos = { x = 210 + (size.sizeswitch.x * i); y = 125 }
    ; size = button_size img
    ; state = Shared_bit.T { bits; index = i }
    ; img
    })
;;

let init_lights ~board_state ~renderer ~(size : Size.t) =
  let img : Button.img =
    { img_active = load_texture ~renderer ~image:Ladyon
    ; img_inactive = load_texture ~renderer ~image:Ladyoff
    }
  in
  let bits = Board_state.lights board_state in
  Array.init v_NUMLIGHT ~f:(fun i ->
    { Button.pos = { x = 20 + (size.sizelight.x * i); y = 10 }
    ; size = button_size img
    ; state = Shared_bit.T { bits; index = i }
    ; img
    })
;;

(* Main GUI context - contains SDL resources and state reference *)
type t =
  { window : Sdl.window
  ; renderer : Sdl.renderer
  ; needs_redraw : bool ref
  ; plates : Plate.t array
  ; lights : Button.t array
  ; pushes : Button.t array
  ; switches : Button.t array
  ; all_buttons : Button.t array
  }

let init ~title ~board_state =
  Sdl.init Sdl.Init.(video + events) |> result_exn;
  let window =
    Sdl.create_window title ~w:v_WINWIDTH ~h:v_WINHEIGHT Sdl.Window.opengl |> result_exn
  in
  let renderer = Sdl.create_renderer window |> result_exn in
  Sdl.set_window_icon window (load_surface ~image:Ladyon);
  let size = Size.create () in
  let pushes = init_pushes ~board_state ~renderer ~size in
  let switches = init_switches ~board_state ~renderer ~size in
  let lights = init_lights ~board_state ~renderer ~size in
  let all_buttons = Array.concat [ pushes; switches; lights ] in
  let plates = init_plates ~renderer ~size in
  { window
  ; renderer
  ; needs_redraw = Board_state.needs_redraw board_state
  ; plates
  ; lights
  ; pushes
  ; switches
  ; all_buttons
  }
;;

(* Render a texture at the given position using its natural dimensions. *)
let render_texture_at renderer texture ~x ~y =
  let _, _, (w, h) = Sdl.query_texture texture |> result_exn in
  let dst_rect = Sdl.Rect.create ~x ~y ~w ~h in
  Sdl.render_copy ~dst:dst_rect renderer texture |> result_exn
;;

(* Main drawing function - renders the complete interface. *)
let redraw (t : t) =
  (* Clear background with dark blue color. *)
  Sdl.set_render_draw_color t.renderer 28 28 69 255 |> result_exn;
  Sdl.render_clear t.renderer |> result_exn;
  Array.iter t.plates ~f:(fun plate ->
    render_texture_at t.renderer plate.img ~x:plate.x ~y:plate.y);
  Array.iter t.all_buttons ~f:(fun (button : Button.t) ->
    render_texture_at
      t.renderer
      (if Button.is_active button then button.img.img_active else button.img.img_inactive)
      ~x:button.pos.x
      ~y:button.pos.y);
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
      let buttons =
        match Random.int 3 with
        | 0 -> t.lights
        | 1 -> t.switches
        | _ -> t.pushes
      in
      let i = Random.int (Array.length buttons) in
      let (Shared_bit.T { bits; index }) = buttons.(i).state in
      bits.(index) <- not bits.(index)
    done)
;;

let handle_mouse_down t ~x ~y =
  (* Handle push button presses (momentary). *)
  (match Button.find t.pushes ~x ~y with
   | None -> ()
   | Some button ->
     t.needs_redraw.contents <- true;
     let (Shared_bit.T { bits; index }) = button.state in
     bits.(index) <- true);
  (* Handle switch toggles (latching). *)
  match Button.find t.switches ~x ~y with
  | None -> ()
  | Some button ->
    t.needs_redraw.contents <- true;
    let (Shared_bit.T { bits; index }) = button.state in
    bits.(index) <- not bits.(index)
;;

let handle_mouse_up t =
  (* Release all push buttons (they're momentary). *)
  Array.iter t.pushes ~f:(fun button ->
    let (Shared_bit.T { bits; index }) = button.state in
    if bits.(index)
    then (
      t.needs_redraw.contents <- true;
      bits.(index) <- false))
;;

(* Main event loop - runs on the GUI thread. *)
let event_loop (t : t) =
  let event = Sdl.Event.create () in
  With_return.with_return (fun return ->
    while true do
      (* Check for redraw requests from other threads. *)
      if t.needs_redraw.contents
      then (
        t.needs_redraw.contents <- false;
        redraw t);
      (* Poll for SDL events with 16ms timeout (≈60 FPS: 1000ms/60 ≈ 16.67ms). *)
      match Sdl.wait_event_timeout (Some event) 16 with
      | false -> () (* timeout, continue loop *)
      | true ->
        (match Sdl.Event.(enum (get event typ)) with
         | `Quit -> return.return ()
         | `Key_down ->
           let keycode = Sdl.Event.get event Sdl.Event.keyboard_keycode in
           if keycode = Sdl.K.escape then return.return ()
         | `Mouse_button_down ->
           let x = Sdl.Event.get event Sdl.Event.mouse_button_x in
           let y = Sdl.Event.get event Sdl.Event.mouse_button_y in
           handle_mouse_down t ~x ~y
         | `Mouse_button_up -> handle_mouse_up t
         | _ -> ())
    done);
  destroy_and_quit t
;;

(* Main command - uses bopkit_block.main to preserve all standard CLI options,
   with clean state separation allowing safe multi-threading. *)
let run_cmd =
  Bopkit_block.main
    (let open Command.Std in
     let+ title =
       Arg.named_with_default
         [ "title" ]
         Param.string
         ~default:"bopboard"
         ~docv:"TITLE"
         ~doc:"Set window title."
     in
     (* Create shared state accessible to both threads. *)
     let board_state = create_board_state () in
     (* Start GUI on auxiliary thread. *)
     let (_ : Thread.t) =
       Thread.create
         (fun () ->
            let t = init ~title ~board_state in
            event_loop t)
         ()
     in
     (* Return bopkit block to run immediately on main thread *)
     Board_state.bopkit_block board_state)
;;

let stress_test_cmd =
  Command.make
    ~summary:"A stress test for the bopboard."
    (let open Command.Std in
     let+ () = Arg.return () in
     let board_state = create_board_state () in
     let t = init ~title:"Bopboard Stress Test" ~board_state in
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
