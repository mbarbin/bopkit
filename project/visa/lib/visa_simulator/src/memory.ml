module Ram = struct
  type t = int Hashtbl.M(Int).t

  let create () = Hashtbl.create (module Int)

  let sexp_of_t t =
    t
    |> Hashtbl.to_alist
    |> List.sort ~compare:(fun (a, _) (b, _) -> Int.compare a b)
    |> [%sexp_of: (int * int) list]
  ;;

  let blit t ~(memory : Bit_matrix.t) =
    Array.iteri memory ~f:(fun key data ->
      let data = Bit_array.to_int data in
      Hashtbl.change t key ~f:(fun _ ->
        match data with
        | 0 -> None
        | _ -> Some data))
  ;;
end

type t =
  { mutable register_R0 : int
  ; mutable register_R1 : int
  ; mutable overflow_flag : bool
  ; output_device : Output_device.t
  ; memory : Ram.t
  }
[@@deriving sexp_of]

let create () =
  { register_R0 = 0
  ; register_R1 = 0
  ; overflow_flag = false
  ; memory = Ram.create ()
  ; output_device = Output_device.create ~len:8
  }
;;

let load_initial_memory t memory =
  let dimx = Bit_matrix.dimx memory in
  let dimy = Bit_matrix.dimy memory in
  if not (dimx = 256 && dimy = 8)
  then
    raise_s
      [%sexp
        "Invalid memory dimension. Expected [256 x 8]."
      , [%here]
      , { dimx : int; dimy : int }];
  Ram.blit t.memory ~memory
;;

let output_device t = t.output_device

let register_value t ~register_name =
  match (register_name : Visa.Register_name.t) with
  | R0 -> t.register_R0
  | R1 -> t.register_R1
;;

let fetch t ~address =
  Hashtbl.find t.memory (Visa.Address.to_int address) |> Option.value ~default:0
;;

let load_value t ~value ~register_name =
  match (register_name : Visa.Register_name.t) with
  | R0 -> t.register_R0 <- value
  | R1 -> t.register_R1 <- value
;;

let load t ~address ~register_name =
  let value = fetch t ~address in
  load_value t ~value ~register_name
;;

let store t ~register_name ~address =
  let address = Visa.Address.to_int address in
  let value = register_value t ~register_name in
  Hashtbl.set t.memory ~key:address ~data:value
;;

let write t ~register_name ~address =
  let address = Visa.Address.to_int address in
  let value = register_value t ~register_name in
  Output_device.set t.output_device ~address ~value
;;

let add t =
  let result = t.register_R0 + t.register_R1 in
  t.overflow_flag <- result > 255;
  t.register_R1 <- result % 256
;;

let overflow_flag t = t.overflow_flag
let gof t = t.register_R1 <- (if t.overflow_flag then 1 else 0)
let and_ t = t.register_R1 <- t.register_R0 land t.register_R1

let switch t =
  let tmp = t.register_R1 in
  t.register_R1 <- t.register_R0;
  t.register_R0 <- tmp
;;

let cmp t = t.register_R1 <- (if t.register_R0 = t.register_R1 then 1 else 0)

let not_ t ~register_name =
  match (register_name : Visa.Register_name.t) with
  | R0 -> t.register_R0 <- lnot t.register_R0 % 256
  | R1 -> t.register_R1 <- lnot t.register_R1 % 256
;;
