type t =
  | Ladybgleft
  | Ladybgmid
  | Ladybgright
  | Ladyoff
  | Ladyon
  | Pushbg
  | Pushdown
  | Pushup
  | Switchbg
  | Switchdown
  | Switchup
[@@deriving enumerate, equal, sexp_of]

let basename = function
  | Ladybgleft -> "ladybgleft01.png"
  | Ladybgmid -> "ladybgmid01.png"
  | Ladybgright -> "ladybgright01.png"
  | Ladyoff -> "ladyoff01.png"
  | Ladyon -> "ladyon01.png"
  | Pushbg -> "pushbg01.png"
  | Pushdown -> "pushdown01.png"
  | Pushup -> "pushup01.png"
  | Switchbg -> "switchbg01.png"
  | Switchdown -> "switchdown01.png"
  | Switchup -> "switchup01.png"
;;
