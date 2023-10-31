let horizontal_segment_polygon d x y =
  let u = 4 * d in
  let d2 = 2 * d in
  let u5 = 5 * u in
  let u6 = 6 * u in
  [| x, y
   ; x + d2, y + d2
   ; x + d2 + u5, y + d2
   ; x + u6, y
   ; x + d2 + u5, y - d2
   ; x + d2, y - d2
   ; x, y
  |]
;;

let vertical_segment_polygon di d x y =
  let di2 = 2 * di in
  let u = 4 * d in
  let d2 = 2 * d in
  let u5 = 5 * u in
  let u6 = 6 * u in
  [| x, y
   ; x - d2, y + d2
   ; x - d2 + di2, y + d2 + u5
   ; x + di2, y + u6
   ; x + d2 + di2, y + d2 + u5
   ; x + d2, y + d2
   ; x, y
  |]
;;

module Coordinates = struct
  type t =
    { frame : int * int * int * int
    ; segments : (int * int) array array
    ; text_box : int * int * int * int
    ; text : (int * int) array
    ; wires : (int * int) array array
    ; wire_attachment_points : (int * int) array
    }

  let create ~size:d ~x ~y =
    let p = float_of_int d /. 5. in
    let cm = 2 * d in
    let hh = horizontal_segment_polygon d
    and vv = vertical_segment_polygon d d in
    let segments =
      [| vv (x + (6 * cm)) (y + (22 * cm) + d)
       ; hh (x + (6 * cm) + d) (y + (22 * cm))
       ; vv (x + (5 * cm)) (y + (9 * cm) + d)
       ; hh (x + (5 * cm) + d) (y + (9 * cm))
       ; vv (x + (18 * cm)) (y + (9 * cm) + d)
       ; vv (x + (19 * cm)) (y + (22 * cm) + d)
       ; hh (x + (7 * cm) + d) (y + (35 * cm))
      |]
    and text =
      let ip = int_of_float p in
      let dy = if d >= 3 then 4 * d else 3 * d in
      [| x + (5 * cm) + ip, y + dy
       ; x + (7 * cm) + ip, y + dy
       ; x + (9 * cm) + ip, y + dy
       ; x + (11 * cm) + ip, y + dy
       ; x + (13 * cm) + ip, y + dy
       ; x + (15 * cm) + ip, y + dy
       ; x + (17 * cm) + ip, y + dy
      |]
    and wires =
      [| [| x + (5 * cm), y + (23 * cm) + d
          ; x + int_of_float (33. *. p), y + (23 * cm) + d
          ; x + int_of_float (16. *. p), y + (6 * cm) + d
          ; x + (5 * cm) + d, y + (6 * cm) + d
          ; x + (5 * cm) + d, y + (5 * cm)
         |]
       ; [| x + (6 * cm) + d, y + (22 * cm)
          ; x + int_of_float (42. *. p), y + (22 * cm)
          ; x + int_of_float (26. *. p), y + (7 * cm)
          ; x + (7 * cm) + d, y + (7 * cm)
          ; x + (7 * cm) + d, y + (5 * cm)
         |]
       ; [| x + (5 * cm), y + (9 * cm) + d
          ; x + int_of_float (47. *. p), y + (7 * cm) + d
          ; x + (9 * cm) + d, y + (7 * cm) + d
          ; x + (9 * cm) + d, y + (5 * cm)
         |]
       ; [| x + (11 * cm) + d, y + (8 * cm); x + (11 * cm) + d, y + (5 * cm) |]
       ; [| x + (18 * cm), y + (9 * cm) + d
          ; x + int_of_float (178. *. p), y + (7 * cm) + d
          ; x + (13 * cm) + d, y + (7 * cm) + d
          ; x + (13 * cm) + d, y + (5 * cm)
         |]
       ; [| x + (20 * cm), y + (23 * cm) + d
          ; x + int_of_float (213. *. p), y + (23 * cm) + d
          ; x + int_of_float (197. *. p), y + (7 * cm)
          ; x + (15 * cm) + d, y + (7 * cm)
          ; x + (15 * cm) + d, y + (5 * cm)
         |]
       ; [| x + (19 * cm) + d, y + (35 * cm)
          ; x + int_of_float (234. *. p), y + (35 * cm)
          ; x + int_of_float (207. *. p), y + (6 * cm) + d
          ; x + (17 * cm) + d, y + (6 * cm) + d
          ; x + (17 * cm) + d, y + (5 * cm)
         |]
      |]
    and wire_attachment_points =
      [| x + (5 * cm), y + (23 * cm) + d
       ; x + (6 * cm) + d, y + (22 * cm)
       ; x + (5 * cm), y + (9 * cm) + d
       ; x + (11 * cm) + d, y + (8 * cm)
       ; x + (18 * cm), y + (9 * cm) + d
       ; x + (20 * cm), y + (23 * cm) + d
       ; x + (19 * cm) + d, y + (35 * cm)
      |]
    in
    { frame = x, y, 25 * cm, 38 * cm
    ; segments
    ; text_box = x + (4 * cm), y + cm, 15 * cm, 3 * cm
    ; text
    ; wires
    ; wire_attachment_points
    }
  ;;
end

type t =
  { colors : Colors.t
  ; segments_state : bool array
  ; coordinates : Coordinates.t
  }

let create ~colors ~size ~x ~y =
  { colors
  ; segments_state = Array.create ~len:7 false
  ; coordinates = Coordinates.create ~size ~x ~y
  }
;;

let wire_attachment_points_radius = 3

let refresh_wire_attachment_points t i =
  match t.coordinates.wire_attachment_points.(i) with
  | a, b -> Graphics.fill_circle a b wire_attachment_points_radius
;;

let refresh_segment t i =
  Graphics.set_color (if t.segments_state.(i) then t.colors.on else t.colors.off);
  Graphics.fill_poly t.coordinates.segments.(i);
  Graphics.set_color t.colors.wires;
  refresh_wire_attachment_points t i
;;

let update_segment t i new_val =
  t.segments_state.(i) <- new_val;
  refresh_segment t i
;;

let plot_string_state t =
  Graphics.set_color t.colors.background;
  (match t.coordinates.text_box with
   | a, b, l, h -> Graphics.fill_rect a b l h);
  Graphics.set_color t.colors.on;
  for i = 0 to 6 do
    match t.coordinates.text.(i) with
    | a, b ->
      Graphics.moveto a b;
      Graphics.draw_char (if t.segments_state.(i) then '1' else '0')
  done
;;

let init t =
  Graphics.set_color t.colors.wires;
  for i = 0 to 6 do
    Graphics.draw_poly_line t.coordinates.wires.(i);
    refresh_wire_attachment_points t i
  done;
  for i = 0 to 6 do
    refresh_segment t i
  done;
  Graphics.set_color t.colors.frame;
  (match t.coordinates.frame with
   | a, b, l, h -> Graphics.draw_rect a b l h);
  plot_string_state t
;;

let update t ~src:new_value ~src_pos:index =
  let do_string = ref false in
  for i = 0 to 6 do
    let new_value = new_value.(index + i) in
    if Bool.(t.segments_state.(i) <> new_value)
    then (
      do_string := true;
      update_segment t i new_value)
  done;
  if !do_string then plot_string_state t
;;
