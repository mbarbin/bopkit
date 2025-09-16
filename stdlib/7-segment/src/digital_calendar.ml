(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t =
  { time_digits : Digit.t array
  ; date_digits : Digit.t array
  }

let colors : Colors.t =
  { wires = Graphics.yellow
  ; on = Graphics.magenta
  ; off = Graphics.rgb 0 10 10
  ; background = Graphics.black
  ; frame = Graphics.blue
  }
;;

let init () : t =
  let () =
    Graphics.open_graph " 1000x500";
    Graphics.set_color Graphics.black;
    Graphics.fill_rect 0 0 1000 500;
    Graphics.set_window_title "Bopkit - Digital Calendar";
    Graphics.set_font "monospace-10"
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
  (* The time digits "HH:MM:SS" are given in this order: "54:32:10" from pos:0 *)
  for i = 0 to 5 do
    Digit.update t.time_digits.(i) ~src:input ~src_pos:(7 * (5 - i))
  done;
  (* The date digits "DD:MM:YY" are given in this order: "10:32:54" from pos:49 *)
  for i = 0 to 2 do
    Digit.update t.date_digits.((2 * i) + 1) ~src:input ~src_pos:(49 + (7 * 2 * i));
    Digit.update t.date_digits.(2 * i) ~src:input ~src_pos:(56 + (7 * 2 * i))
  done
;;

module Decoded = struct
  type t =
    { hour : int
    ; minute : int
    ; second : int
    ; day : int
    ; month : int
    ; year : int
    }
  [@@deriving equal, sexp_of]

  let to_string { hour; minute; second; day; month; year } =
    Printf.sprintf "%02d/%02d/%02d - %02d:%02d:%02d" day month year hour minute second
  ;;

  let blit (t : t) ~dst =
    let blit pos d = Seven_segment_code.blit ~digit:d ~dst ~dst_pos:pos in
    blit 0 (t.second % 10);
    blit 7 (t.second / 10);
    blit 14 (t.minute % 10);
    blit 21 (t.minute / 10);
    blit 28 (t.hour % 10);
    blit 35 (t.hour / 10);
    blit 49 (t.day % 10);
    blit 56 (t.day / 10);
    blit 63 (t.month % 10);
    blit 70 (t.month / 10);
    blit 77 (t.year % 10);
    blit 84 (t.year / 10 % 10)
  ;;
end

let decode input =
  let digit ~pos =
    match Seven_segment_code.decode ~src:input ~pos with
    | Some digit -> digit
    | None ->
      raise_s [%sexp "Invalid input", (input : Bit_array.Short_sexp.t), { pos : int }]
  in
  let ofday = Array.init 6 ~f:(fun i -> digit ~pos:(7 * (5 - i))) in
  let date =
    Array.init 6 ~f:(fun j ->
      let pos =
        let i = j / 2 in
        if j % 2 = 0 then 56 + (7 * 2 * i) else 49 + (7 * 2 * i)
      in
      digit ~pos)
  in
  let day = (date.(0) * 10) + date.(1) in
  let month = (date.(2) * 10) + date.(3) in
  let year = (date.(4) * 10) + date.(5) in
  let hour = (ofday.(0) * 10) + ofday.(1) in
  let minute = (ofday.(2) * 10) + ofday.(3) in
  let second = (ofday.(4) * 10) + ofday.(5) in
  { Decoded.hour; minute; second; day; month; year }
;;
