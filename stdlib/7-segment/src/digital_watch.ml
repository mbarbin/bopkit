open! Core

type t = { digits : Digit.t array }

let colors : Colors.t =
  { wires = Graphics.red
  ; on = Graphics.green
  ; off = Graphics.rgb 0 20 0
  ; background = Graphics.black
  ; frame = Graphics.yellow
  }
;;

let init () : t =
  let () =
    Graphics.open_graph " 1000x300";
    Graphics.set_color Graphics.black;
    Graphics.fill_rect 0 0 1000 300;
    Graphics.set_window_title "Bopkit - Digital Watch"
  in
  let space = 150 in
  let x = 14 in
  let y = 30 in
  let digits =
    Array.init 6 ~f:(fun i ->
      Digit.create ~colors ~size:3 ~x:(x + (space * i) + (i / 2 * (space / 4))) ~y)
  in
  Array.iter digits ~f:Digit.init;
  let () =
    let colon_separators =
      [| x + 310, y + 140; x + 645, y + 140; x + 310, y + 110; x + 645, y + 110 |]
    in
    Graphics.set_color colors.on;
    Array.iter colon_separators ~f:(fun (a, b) ->
      Graphics.fill_poly [| a, b; a + 3, b + 12; a + 15, b + 12; a + 12, b; a, b |])
  in
  { digits }
;;

let update (t : t) input =
  Array.iteri t.digits ~f:(fun i digit -> Digit.update digit ~src:input ~src_pos:(7 * i))
;;
