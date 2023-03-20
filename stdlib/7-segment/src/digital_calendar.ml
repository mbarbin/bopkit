open! Core

type t =
  { time_digits : Digit.t array
  ; date_digits : Digit.t array
  }

let colors : Colors.t =
  { wires = Graphics.yellow
  ; on = Graphics.magenta
  ; off = Graphics.rgb 0 30 30
  ; background = Graphics.black
  ; frame = Graphics.blue
  }
;;

let init () : t =
  let () =
    Graphics.open_graph " 1000x500";
    Graphics.set_color Graphics.black;
    Graphics.fill_rect 0 0 1000 500;
    Graphics.set_window_title "Bopkit - Digital Calendar"
  in
  let space_time = 150 in
  let x_t = 14 in
  let y_t = 240 in
  let space_date = 100 in
  let x_d = 150 in
  let y_d = 30 in
  let time_digits =
    Array.init 6 ~f:(fun i ->
      Digit.create
        ~colors
        ~size:3
        ~x:(x_t + (space_time * i) + (i / 2 * (space_time / 4)))
        ~y:y_t)
  in
  let date_digits =
    Array.init 6 ~f:(fun i ->
      Digit.create
        ~colors
        ~size:2
        ~x:(x_d + (space_date * i) + (i / 2 * space_date))
        ~y:y_d)
  in
  Array.iter time_digits ~f:Digit.init;
  Array.iter date_digits ~f:Digit.init;
  let () =
    let time_separators =
      [| x_t + 310, y_t + 140
       ; x_t + 645, y_t + 140
       ; x_t + 310, y_t + 110
       ; x_t + 645, y_t + 110
      |]
    in
    let date_separators = [| x_d + 240, y_d; x_d + 540, y_d |] in
    let draw_separator ver hor dia (a, b) =
      Graphics.fill_poly
        [| a, b; a + dia, b + ver; a + dia + hor, b + ver; a + hor, b; a, b |]
    in
    Graphics.set_color colors.on;
    Array.iter time_separators ~f:(draw_separator 12 12 3);
    Array.iter date_separators ~f:(draw_separator 150 6 10)
  in
  { time_digits; date_digits }
;;

let update (t : t) input =
  (* le tableau est donné a l'envers (91 booleens) *)
  for i = 0 to 5 do
    (* les chiffres de la montre sont codés de gauche à droite *)
    Digit.update t.time_digits.(i) ~src:input ~src_pos:(7 * (5 - i))
  done;
  (* les chiffres de la date : donnés de gauche à droite, unité, dizaine *)
  for i = 0 to 2 do
    Digit.update t.date_digits.((2 * i) + 1) ~src:input ~src_pos:(49 + (7 * 2 * i));
    Digit.update t.date_digits.(2 * i) ~src:input ~src_pos:(56 + (7 * 2 * i))
  done
;;
