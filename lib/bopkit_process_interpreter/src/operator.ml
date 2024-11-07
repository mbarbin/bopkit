type t =
  { operator_name : Bopkit_process.Operator_name.t
  ; arity : int
  ; compute : operands:Bit_array.t array -> unit Or_error.t
  }
[@@deriving fields]

let sexp_of_t { operator_name; arity; compute = _ } =
  [%sexp
    { operator_name : Bopkit_process.Operator_name.t
    ; arity : int
    ; compute = "<abstract>"
    }]
;;

let check_input_length ~input ~expected_length =
  let length = Array.length input in
  if expected_length = length
  then Or_error.return ()
  else
    Or_error.error_s
      [%sexp "Unexpected input length", { expected_length : int; length : int }]
;;

let unary ~operator_name ~compute =
  let compute ~operands:input =
    let%bind.Or_error () = check_input_length ~input ~expected_length:2 in
    compute ~dst:input.(0) input.(1)
  in
  { operator_name; arity = 1; compute }
;;

let binary ~operator_name ~compute =
  let compute ~operands:input =
    let%bind.Or_error () = check_input_length ~input ~expected_length:3 in
    compute ~dst:input.(0) input.(1) input.(2)
  in
  { operator_name; arity = 2; compute }
;;

let p_not ~dst a = Bit_array.blit_init ~dst ~f:(fun i -> not a.(i))

let p_xor ~dst p q =
  Bit_array.blit_init ~dst ~f:(fun i -> if p.(i) then not q.(i) else q.(i))
;;

let p_or ~dst p q = Bit_array.blit_init ~dst ~f:(fun i -> p.(i) || q.(i))
let p_and ~dst p q = Bit_array.blit_init ~dst ~f:(fun i -> p.(i) && q.(i))

let p_add ~dst p q =
  let i = Bit_array.to_int p
  and j = Bit_array.to_int q in
  Bit_array.blit_int ~dst ~src:(i + j)
;;

let p_sub ~dst p q =
  let i = Bit_array.to_int p
  and j = Bit_array.to_int q in
  Bit_array.blit_int ~dst ~src:(i - j)
;;

module Env = struct
  type nonrec t = t Map.M(Bopkit_process.Operator_name).t
end

let primitives : Env.t Lazy.t =
  let u operator_name f : t =
    let operator_name = Bopkit_process.Operator_name.of_string operator_name in
    unary ~operator_name ~compute:(fun ~dst a ->
      f ~dst a;
      Or_error.return ())
  in
  let b operator_name f : t =
    let operator_name = Bopkit_process.Operator_name.of_string operator_name in
    binary ~operator_name ~compute:(fun ~dst a b ->
      f ~dst a b;
      Or_error.return ())
  in
  lazy
    ([ u "not" p_not
     ; b "^" p_xor
     ; b "|" p_or
     ; b "\\/" p_or
     ; b "&" p_and
     ; b "/\\" p_and
     ; b "+" p_add
     ; b "-" p_sub
     ]
     |> List.map ~f:(fun t -> t.operator_name, t)
     |> Map.of_alist_exn (module Bopkit_process.Operator_name))
;;
