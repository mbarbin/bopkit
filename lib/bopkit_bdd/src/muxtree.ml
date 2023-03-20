open! Core
open! Import

module T = struct
  type t =
    | Constant of bool option
    | Signal of Ident.t
    | Not_signal of Ident.t
    | Mux of
        { input : int
        ; vdd : t
        ; gnd : t
        }
  [@@deriving compare, equal, hash, sexp_of]
end

include T
include Comparator.Make (T)

let rec normalize = function
  | Constant _ as t -> t
  | Signal _ as t -> t
  | Not_signal _ as t -> t
  | Mux { input = i; vdd = m1; gnd = m2 } ->
    (match normalize m1, normalize m2 with
     | Constant None, fix | fix, Constant None ->
       (* Assign unspecified bit. *)
       fix
     | Constant (Some true), Constant (Some false) ->
       (* Identity. *)
       Signal (Input i)
     | Constant (Some false), Constant (Some true) ->
       (* Negation *)
       Not_signal (Input i)
     | nm1, nm2 -> if equal nm1 nm2 then nm1 else Mux { input = i; vdd = nm1; gnd = nm2 })
;;

(* A note about a potential extensions to [normalize] to consider:

   {[
      match nm1, nm2 with
      | Mux(j, a, b), Mux(k, c, d) when j = k ->
        if MuxTreeOrder.compare a c = 0
        then Mux(j, a, Mux(i, b, d)) (* Saving 1 Mux *)
        else if MuxTreeOrder.compare b d = 0
        then Mux(j, Mux(i, a, c), b) (* Saving 1 Mux *)
        else Mux(i, nm1, nm2)
      | _ -> Mux (i, nm1, nm2)
   ]}
*)

let log2 n = Caml.Float.log2 (float_of_int n) |> int_of_float

let of_partial_bit_matrix (pbm : Partial_bit_matrix.t) =
  let len = Array.length pbm in
  let num_input_bits = log2 len in
  (* This function is only defined on partial bit matrix encoding for a boolean
     function. *)
  assert (Int.pow 2 num_input_bits = len);
  let muxtree i =
    let rec aux v2_pow_j accu j =
      if j = num_input_bits
      then Constant pbm.(accu).(i)
      else (
        let v2_pow_j2 = v2_pow_j * 2 in
        let succ_j = succ j in
        Mux
          { input = j
          ; vdd = aux v2_pow_j2 (accu + v2_pow_j) succ_j
          ; gnd = aux v2_pow_j2 accu succ_j
          })
    in
    normalize (aux 1 0 0)
  in
  List.init (Array.length pbm.(0)) ~f:muxtree
;;

let rec number_of_gates = function
  | Constant _ | Signal _ -> 0
  | Not_signal _ -> 1
  | Mux { input = _; vdd; gnd } -> 1 + number_of_gates vdd + number_of_gates gnd
;;
