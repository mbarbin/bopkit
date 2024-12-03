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

let all = lazy (Array.init 10 ~f:(fun i -> Array.map (of_digit i) ~f:bool_of_int))

let blit ~digit ~dst ~dst_pos =
  Array.blit ~src:(Lazy.force all).(digit) ~src_pos:0 ~dst ~dst_pos ~len:7
;;

let pattern =
  {|
   66
  0  5
   11
  2  4
   33
|}
;;

let pattern_char = function
  | 1 | 3 | 6 -> '-'
  | 0 | 2 | 4 | 5 -> '|'
  | _ -> assert false
;;

let to_ascii ~digit =
  let t = of_digit digit in
  String.map pattern ~f:(fun c ->
    let code = Char.to_int c - Char.to_int '0' in
    if code >= 0 && code <= 6
    then if bool_of_int t.(code) then pattern_char code else ' '
    else c)
;;

let decode ~src ~pos =
  if pos + 7 > Array.length src
  then None
  else (
    let segment = Array.init 7 ~f:(fun i -> if src.(pos + i) then 1 else 0) in
    Array.find (Array.init 10 ~f:Fn.id) ~f:(fun digit ->
      [%equal: int Array.t] segment (of_digit digit)))
;;
