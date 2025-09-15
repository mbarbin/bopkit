(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type rom
type ram

module Kind = struct
  type 'a t =
    | Ram : ram t
    | Rom : rom t
end

module Word_printing_style = struct
  type t =
    | Decimal
    | SignedDecimal
    | Binary
  [@@deriving equal, sexp_of]
end

type color = Graphics.color

type _ t =
  { name : string
  ; data_width : int (* Size of words in memory. *)
  ; address_width : int (* Size of addresses in bits. *)
  ; length : int (* Number of words in memory: [= 2 ^ address_width]. *)
  ; mem : Bit_matrix.t
  ; mutable tX_and_tY : (int * int) option
  ; mutable bx : int option (* x dimension of a cell rectangle *)
  ; mutable by : int option (* y dimension of a cell rectangle *)
  ; mutable gnd : color
  ; pen : color
  ; mutable coloration : (color * int) Map.M(Int).t
  ; mutable word_printing_style : Word_printing_style.t
  ; mutable offset :
      (* Variable containing the index of cell to display at the upper left
         corner of the view. This is used for large memory that won't fit on a
         single page. *)
      int
  ; mutable edit_mode :
      (* During the event_loop the user can edit values, during which case
         edit_mode will be true. This can be accessed by another thread. *)
      bool
  ; mutable pause_mode : bool
  ; num_dec_char_addr : int
  ; num_dec_char_word : int
  }

exception Escape_key_pressed [@@deriving sexp_of]

(* Cells looks like this, and here are their dimensions (bx x by):

   {v
           bx : (address + 3 + words + 2) * tX
    ------------------
   | 01001 : 00010101 | by = tY + 2 * 2 = 17
    ------------------
   v}
*)

(* Because we do not want to call [text_size] before any drawing function, the
   values related to text size are mutable options, and stay set to [None] until
   needed. *)

let tX_and_tY t =
  match t.tX_and_tY with
  | Some value -> value
  | None ->
    let value = Graphics.text_size "0" in
    t.tX_and_tY <- Some value;
    value
;;

let tX t = fst (tX_and_tY t)
let tY t = snd (tX_and_tY t)
let bx_binary t = (t.address_width + 3 + t.data_width + 2) * tX t
let bx_decimal t = (t.num_dec_char_addr + 3 + t.num_dec_char_word + 2) * tX t
let bx_signed_decimal t = (t.num_dec_char_addr + 3 + t.num_dec_char_word + 1 + 2) * tX t
let by_default t = tY t + (2 * 2)

let bx t =
  match t.bx with
  | Some value -> value
  | None ->
    let value = bx_binary t in
    t.bx <- Some value;
    value
;;

let by t =
  match t.by with
  | Some value -> value
  | None ->
    let value = by_default t in
    t.by <- Some value;
    value
;;

module Ram = struct
  type nonrec t = ram t
end

module Rom = struct
  type nonrec t = rom t
end

let create
  : type a.
    name:string
    -> address_width:int
    -> data_width:int
    -> kind:a Kind.t
    -> ?init:Bit_matrix.t
    -> unit
    -> a t
  =
  fun ~name ~address_width ~data_width ~kind:_ ?init () ->
  let length = Int.pow 2 address_width in
  let values =
    match init with
    | Some values -> values
    | None ->
      Bit_matrix.init_matrix_linear ~dimx:length ~dimy:data_width ~f:(Fn.const false)
  in
  let max_value = Int.pow 2 data_width in
  let mem =
    let t = Array.make_matrix ~dimx:length ~dimy:data_width false in
    for i = 0 to Int.pred (min length (Array.length values)) do
      for j = 0 to Int.pred (min data_width (Array.length values.(i))) do
        t.(i).(j) <- values.(i).(j)
      done
    done;
    t
  in
  let num_dec_char_addr = String.length (Int.to_string length) in
  let num_dec_char_word = String.length (Int.to_string max_value) in
  { name
  ; data_width
  ; address_width
  ; length
  ; mem
  ; tX_and_tY = None
  ; bx = None
  ; by = None
  ; gnd = Graphics.white
  ; pen = Graphics.black
  ; coloration = Map.empty (module Int)
  ; word_printing_style = Word_printing_style.Binary
  ; offset = 0
  ; edit_mode = false
  ; pause_mode = false
  ; num_dec_char_addr
  ; num_dec_char_word
  }
;;

(* Add some leading '0' to a decimal, to achieve vertical alignment. For
   example: int_d 4 15 --> "0015" *)
let int_d d i = Printf.sprintf "%0*d" d i

(* Same as [int_d] but with an additional +/- leading char. For example:
   ind_d_signed 4 -15 --> "-015" *)
let int_d_signed d i =
  Printf.sprintf "%c%0*d" (if i < 0 then '-' else '+') (d - 1) (Int.abs i)
;;

(* The user can cycle through different colors when clicking on the cells. *)
let color_of_click n =
  let open Graphics in
  match n with
  | 0 -> white
  | 1 -> yellow
  | 2 -> green
  | 3 -> cyan
  | 4 -> blue
  | 5 -> magenta
  | 6 -> red
  | _ -> white
;;

let from_rgb (c : Graphics.color) = c / Int.pow 256 2, c / 256 % 256, c % 256
let ( |*. ) i f = Int.of_float (Float.of_int i *. f)

let scale_color color p =
  let r, g, b = from_rgb color in
  Graphics.rgb (r |*. p) (g |*. p) (b |*. p)
;;

(* To make some colors lighter. *)
let parameter = 2.0

(* Interactive read of a string in the OCaml Graphics window, at the coordinate
   (xi, yi). This returns when the user presses <enter>. This draws the string
   as the user types it, and allows for corrections with backspace.

   The returned doesn't contain the terminating '\n' char. *)
let read_string t ~at_coordinates:(xi, yi) ?length ?gnd_color ?(prompt = "") () =
  let open Graphics in
  let tX = tX t
  and by = by t in
  let background_color =
    match gnd_color with
    | Some c -> c
    | None -> rgb 255 0 255
  in
  let fin = ref false in
  let acc = Stack.create () in
  set_color background_color;
  (match length with
   | Some len -> fill_rect xi yi ((len * tX) + 2) by
   | None -> fill_rect xi yi (2 * tX * String.length prompt) by);
  set_color black;
  moveto (xi + 2) (yi + 2);
  draw_string prompt;
  while not !fin do
    let stat = wait_next_event [ Key_pressed ] in
    match stat.key with
    | o when Char.to_int o = 27 -> raise Escape_key_pressed
    | o when Char.to_int o = 13 -> fin := true
    | o when Char.to_int o = 8 ->
      if Stack.is_empty acc
      then ()
      else (
        ignore (Stack.pop acc : Char.t option);
        let x, y = current_x (), current_y () in
        set_color background_color;
        moveto (x - tX) y;
        fill_rect (x - tX) (y - 2) tX by;
        set_color black)
    | o ->
      let get_o () =
        Stack.push acc o;
        draw_char o
      in
      (match length with
       | Some len -> if Stack.length acc >= len then () else get_o ()
       | None -> get_o ())
  done;
  let len = Stack.length acc in
  let out = Bytes.make len ' ' in
  for i = Int.pred len downto 0 do
    Bytes.set out i (Stack.pop_exn acc)
  done;
  Bytes.to_string out
;;

(* Depending on the size of the currently opened graph and the current settings,
   return the number of memory cells that can fit per line and per column, and
   per page. *)
let bx_per_line t = Graphics.size_x () / bx t
let by_per_column t = Graphics.size_y () / by t
let cells_per_page t = by_per_column t * bx_per_line t

let clear_screen t =
  let open Graphics in
  set_color t.gnd;
  fill_rect 0 0 (size_x ()) (size_y ())
;;

let draw_color t =
  let open Graphics in
  let sY = size_y () in
  let bx = bx t in
  let by = by t in
  let byc = by_per_column t in
  let cpp = cells_per_page t in
  let f_iter t = if t then draw_char '1' else draw_char '0' in
  let f_list adr col =
    if adr < t.offset || adr >= t.offset + cpp
    then ()
    else (
      let i = adr - t.offset
      and bits_adr = Array.create ~len:t.address_width false in
      moveto (0 + (bx * (i / byc))) (sY - by - (by * (i % byc)) + 2);
      set_color (scale_color col parameter);
      fill_rect (current_x ()) (current_y () - 2) bx by;
      set_color t.pen;
      Bit_array.blit_int ~dst:bits_adr ~src:adr;
      draw_char ' ';
      match t.word_printing_style with
      | Binary ->
        Array.iter ~f:f_iter bits_adr;
        draw_string " : ";
        Array.iter ~f:f_iter t.mem.(adr)
      | Decimal ->
        draw_string (int_d t.num_dec_char_addr (Bit_array.to_int bits_adr));
        draw_string " : ";
        draw_string (int_d t.num_dec_char_word (Bit_array.to_int t.mem.(adr)))
      | SignedDecimal ->
        draw_string (int_d t.num_dec_char_addr (Bit_array.to_int bits_adr));
        draw_string " : ";
        draw_string
          (int_d_signed (t.num_dec_char_word + 1) (Bit_array.to_signed_int t.mem.(adr))))
  in
  Map.iteri t.coloration ~f:(fun ~key:adr ~data:(col, _) -> f_list adr col)
;;

let draw t =
  let open Graphics in
  let sY = size_y () in
  let bx = bx t in
  let by = by t in
  let byc = by_per_column t in
  let cpp = cells_per_page t in
  let f_iter t = if t then draw_char '1' else draw_char '0' in
  clear_screen t;
  set_color t.pen;
  (* Here we draw them all without considerations for colors, and we redraw the
     colored one at the end. *)
  for i = 0 to Int.pred (min cpp (t.length - t.offset)) do
    let j = i + t.offset
    and bits_adr = Array.create ~len:t.address_width false in
    moveto (0 + (bx * (i / byc))) (sY - by - (by * (i % byc)) + 2);
    Bit_array.blit_int ~dst:bits_adr ~src:j;
    draw_char ' ';
    match t.word_printing_style with
    | Binary ->
      Array.iter ~f:f_iter bits_adr;
      draw_string " : ";
      Array.iter ~f:f_iter t.mem.(j)
    | Decimal ->
      draw_string (int_d t.num_dec_char_addr (Bit_array.to_int bits_adr));
      draw_string " : ";
      draw_string (int_d t.num_dec_char_word (Bit_array.to_int t.mem.(j)))
    | SignedDecimal ->
      draw_string (int_d t.num_dec_char_addr (Bit_array.to_int bits_adr));
      draw_string " : ";
      draw_string
        (int_d_signed (t.num_dec_char_word + 1) (Bit_array.to_signed_int t.mem.(j)))
  done;
  draw_color t
;;

let set_word_printing_style t ~word_printing_style:new_type =
  t.word_printing_style <- new_type;
  (match new_type with
   | Decimal ->
     t.bx <- Some (bx_decimal t);
     t.by <- Some (by_default t)
   | SignedDecimal ->
     t.bx <- Some (bx_signed_decimal t);
     t.by <- Some (by_default t)
   | Binary ->
     t.bx <- Some (bx_binary t);
     t.by <- Some (by_default t));
  draw t
;;

let set_color t ~address:adr ~color:col =
  t.coloration <- Map.set t.coloration ~key:adr ~data:(col, 0)
;;

let get_color t ~address:adr = Map.find t.coloration adr |> Option.map ~f:fst

(* Cycle through the background colors of cells when the user clicks on them. *)
let click_color t ~address =
  if address < 0 || address >= t.length
  then ()
  else (
    let new_state =
      match Map.find t.coloration address with
      | Some (_, s) -> Int.succ s % 7
      | None -> 1
    in
    t.coloration
    <- Map.set t.coloration ~key:address ~data:(color_of_click new_state, new_state))
;;

let reset_color t ~address = t.coloration <- Map.remove t.coloration address

let set_color_option t ~address ~color =
  match color with
  | None -> reset_color t ~address
  | Some col -> set_color t ~address ~color:col
;;

let reset_all_color t = t.coloration <- Map.empty (module Int)

let scroll_to_next_page t =
  let cpp = cells_per_page t in
  if t.offset + cpp >= t.length
  then ()
  else (
    let cpp2 = cpp / 2 in
    t.offset <- min (t.offset + cpp2) (t.length - cpp2))
;;

let scroll_to_previous_page t =
  let cpp2 = cells_per_page t / 2 in
  t.offset <- max 0 (t.offset - cpp2)
;;

let center_view t ~on_address =
  if on_address > t.offset + cells_per_page t
  then (
    let cpp2 = cells_per_page t / 2 in
    t.offset <- max 0 (on_address - cpp2);
    `Done_now_needs_to_redraw)
  else `Not_needed_did_nothing
;;

(* Prompt the user for a new value for the memory cell at the given address. *)
let read_user_value t ~address:addr =
  let sY = Graphics.size_y () in
  let tX = tX t in
  let bx = bx t in
  let by = by t in
  let byc = by_per_column t in
  let cpp = cells_per_page t in
  if addr < 0 || addr > t.length
  then ()
  else (
    if addr > t.offset + cpp
    then (
      ignore
        (center_view t ~on_address:addr
         : [ `Done_now_needs_to_redraw | `Not_needed_did_nothing ]);
      draw t)
    else ();
    let i = addr - t.offset in
    match t.word_printing_style with
    | Binary ->
      let dx, dy =
        (bx * (i / byc)) + (tX * (t.address_width + 4)), sY - by - (by * (i % byc))
      in
      let s_user = read_string t ~at_coordinates:(dx - 2, dy) ~length:t.data_width () in
      let tmp = Bit_array.of_01_chars_in_string s_user in
      Array.blit
        ~src:tmp
        ~src_pos:0
        ~dst:t.mem.(addr)
        ~dst_pos:0
        ~len:(min (Array.length tmp) t.data_width)
    | Decimal ->
      let dx, dy =
        (bx * (i / byc)) + (tX * (t.num_dec_char_addr + 4)), sY - by - (by * (i % byc))
      in
      let s_user =
        read_string t ~at_coordinates:(dx - 2, dy) ~length:t.num_dec_char_word ()
      in
      (match Int.of_string_opt s_user with
       | None -> ()
       | Some iv -> Bit_array.blit_int ~dst:t.mem.(addr) ~src:iv)
    | SignedDecimal ->
      let dx, dy =
        (bx * (i / byc)) + (tX * (t.num_dec_char_addr + 4)), sY - by - (by * (i % byc))
      in
      let s_user =
        read_string t ~at_coordinates:(dx - 2, dy) ~length:(t.num_dec_char_word + 1) ()
      in
      (match Int.of_string_opt s_user with
       | None -> ()
       | Some iv -> Bit_array.blit_int ~dst:t.mem.(addr) ~src:iv))
;;

let to_text_file t ~path =
  prerr_endline
    (Printf.sprintf
       "Save memory \"%s\" to \"%s\" (text file)"
       t.name
       (path |> Fpath.to_string));
  Bit_matrix.to_text_file t.mem ~path
;;

let load_text_file t ~path =
  prerr_endline
    (Printf.sprintf
       "Load memory \"%s\" from \"%s\" (text file)"
       t.name
       (path |> Fpath.to_string));
  let bin = Bit_matrix.of_text_file ~dimx:t.length ~dimy:t.data_width ~path in
  for i = 0 to Int.pred t.length do
    for j = 0 to Int.pred t.data_width do
      t.mem.(i).(j) <- bin.(i).(j)
    done
  done
;;

let pause_mode t = t.pause_mode

let event_loop_internal t ~loop ~read_only =
  let open Graphics in
  let mode_edit_off () =
    if t.edit_mode
    then (
      t.edit_mode <- false;
      t.gnd <- white)
    else ()
  in
  let mode_edit_on () =
    if t.edit_mode
    then ()
    else (
      t.edit_mode <- true;
      t.gnd <- rgb 255 254 255)
  in
  let switch_edit () =
    match t.edit_mode with
    | true -> mode_edit_off ()
    | false -> mode_edit_on ()
  in
  With_return.with_return (fun return ->
    mode_edit_off ();
    draw t;
    while true do
      let must_draw =
        let stat = wait_next_event [ Key_pressed; Button_down ] in
        if stat.keypressed
        then (
          match stat.key with
          | 'p' ->
            t.pause_mode <- not t.pause_mode;
            false
          | 'e' ->
            if read_only
            then false
            else (
              mode_edit_on ();
              true)
          | 'r' ->
            if read_only
            then false
            else (
              mode_edit_off ();
              true)
          | '1' ->
            set_word_printing_style t ~word_printing_style:Binary;
            true
          | '2' ->
            set_word_printing_style t ~word_printing_style:Decimal;
            true
          | '3' ->
            set_word_printing_style t ~word_printing_style:SignedDecimal;
            true
          | '<' ->
            scroll_to_previous_page t;
            true
          | '>' ->
            scroll_to_next_page t;
            true
          | '!' ->
            reset_all_color t;
            true
          | 's' ->
            let prompt = Printf.sprintf "Save memory \"%s\" as : " t.name in
            let path = read_string t ~at_coordinates:(0, 0) ~prompt () |> Fpath.v in
            to_text_file t ~path;
            true
          | 'l' ->
            if read_only
            then false
            else (
              let prompt = Printf.sprintf "Load memory \"%s\" from : " t.name in
              let path = read_string t ~at_coordinates:(0, 0) ~prompt () |> Fpath.v in
              load_text_file t ~path;
              true)
          | o when Char.equal o ' ' || Char.to_int o = 13 (* '\n' *) ->
            (match loop with
             | false -> return.return ()
             | true ->
               if read_only
               then false
               else (
                 switch_edit ();
                 true))
          | o when Char.to_int o = 27 -> raise Escape_key_pressed
          | _ -> false)
        else if stat.button
        then (
          let a = stat.mouse_x / bx t
          and b = (size_y () - stat.mouse_y) / by t in
          let index_on_page = (a * by_per_column t) + b in
          let address = t.offset + index_on_page in
          match t.edit_mode with
          | true ->
            read_user_value t ~address;
            true
          | false ->
            click_color t ~address;
            draw_color t;
            false)
        else false
      in
      if must_draw then draw t else ()
    done)
;;

let wait t = event_loop_internal t ~loop:false ~read_only:false

let event_loop t ~read_only =
  try event_loop_internal t ~loop:true ~read_only with
  | Escape_key_pressed | Graphics.Graphic_failure _ -> ()
;;

let read_int t ~address =
  if address < 0 || address >= t.length
  then (
    prerr_endline
      (Printf.sprintf "Memory %s : read_int out of bounds (%d)" t.name address);
    Stdlib.exit 1)
  else Bit_array.to_int t.mem.(address)
;;

let read_bits t ~address ~dst:where =
  let address = Bit_array.to_int address in
  if address < 0 || address >= t.length
  then (
    prerr_endline
      (Printf.sprintf "Memory %s: read_bits out of bounds (%d)" t.name address);
    Stdlib.exit 1)
  else if Array.length where <> t.data_width
  then (
    prerr_endline (Printf.sprintf "Memory %s: read_bits invalid pointer\n" t.name);
    Stdlib.exit 1)
  else Array.blit ~src:t.mem.(address) ~src_pos:0 ~dst:where ~dst_pos:0 ~len:t.data_width
;;

let write_int t ~address ~value =
  if address < 0 || address >= t.length
  then (
    prerr_endline (Printf.sprintf "RAM %s: write_int out of bounds (%d)\n" t.name address);
    Stdlib.exit 1)
  else Bit_array.blit_int ~dst:t.mem.(address) ~src:value
;;

let write_bits t ~address ~value =
  let address = Bit_array.to_int address in
  if address < 0 || address >= t.length
  then (
    prerr_endline (Printf.sprintf "RAM %s: write_bits out of bounds (%d)" t.name address);
    Stdlib.exit 1)
  else if Array.length value <> t.data_width
  then (
    prerr_endline
      (Printf.sprintf
         "RAM %s: write_bits invalid data (%d)"
         t.name
         (Bit_array.to_int value));
    Stdlib.exit 1)
  else Array.blit ~src:value ~src_pos:0 ~dst:t.mem.(address) ~dst_pos:0 ~len:t.data_width
;;
