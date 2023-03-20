let of_digit = function
  | 0 -> [| 1; 0; 1; 1; 1; 1; 1 |]
  | 1 -> [| 0; 0; 0; 0; 1; 1; 0 |]
  | 2 -> [| 0; 1; 1; 1; 0; 1; 1 |]
  | 3 -> [| 0; 1; 0; 1; 1; 1; 1 |]
  | 4 -> [| 1; 1; 0; 0; 1; 1; 0 |]
  | 5 -> [| 1; 1; 0; 1; 1; 0; 1 |]
  | 6 -> [| 1; 1; 1; 1; 1; 0; 1 |]
  | 7 -> [| 0; 0; 0; 0; 1; 1; 1 |]
  | 8 -> [| 1; 1; 1; 1; 1; 1; 1 |]
  | 9 -> [| 1; 1; 0; 1; 1; 1; 1 |]
  | _ -> failwith "of_digit"
;;

let bool_of_int = function
  | 0 -> false
  | 1 -> true
  | _ -> assert false
;;

let all = lazy (Array.init 10 (fun i -> Array.map bool_of_int (of_digit i)))
let blit ~digit ~dst ~dst_pos = Array.blit (Lazy.force all).(digit) 0 dst dst_pos 7

let pattern = {|
   66
  0  5
   11
  2  4
   33
|}

let pattern_char = function
  | 1 | 3 | 6 -> '-'
  | 0 | 2 | 4 | 5 -> '|'
  | _ -> assert false
;;

let to_ascii ~digit =
  let t = of_digit digit in
  String.map
    (fun c ->
      let code = Char.code c - Char.code '0' in
      if code >= 0 && code <= 6
      then if bool_of_int t.(code) then pattern_char code else ' '
      else c)
    pattern
;;
