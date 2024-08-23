type t = { digits : Digit.t array }

let colors : Colors.t =
  { wires = Graphics.red
  ; on = Graphics.green
  ; off = Graphics.rgb 0 10 0
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

module Decoded = struct
  type t =
    { hour : int
    ; minute : int
    ; second : int
    }
  [@@deriving equal, sexp_of]

  let to_string { hour; minute; second } =
    Printf.sprintf "%02d:%02d:%02d" hour minute second
  ;;

  let blit (t : t) ~dst =
    let blit pos d = Seven_segment_code.blit ~digit:d ~dst ~dst_pos:pos in
    blit 0 (t.hour / 10);
    blit 7 (t.hour % 10);
    blit 14 (t.minute / 10);
    blit 21 (t.minute % 10);
    blit 28 (t.second / 10);
    blit 35 (t.second % 10)
  ;;
end

let decode input =
  let digits =
    Array.init 6 ~f:(fun i ->
      let pos = 7 * i in
      match Seven_segment_code.decode ~src:input ~pos with
      | Some digit -> digit
      | None ->
        raise_s [%sexp "Invalid input", (input : Bit_array.Short_sexp.t), { pos : int }])
  in
  let hour = (digits.(0) * 10) + digits.(1) in
  let minute = (digits.(2) * 10) + digits.(3) in
  let second = (digits.(4) * 10) + digits.(5) in
  { Decoded.hour; minute; second }
;;
