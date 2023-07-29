open! Core

type t =
  | Input
  | Output
  | Id
  | Not
  | And
  | Or
  | Xor
  | Mux
  | Rom of
      { loc : Loc.t
      ; name : string
      ; index : int
      }
  | Ram of
      { loc : Loc.t
      ; name : string
      ; address_width : int
      ; data_width : int
      ; contents : Bit_matrix.t [@sexp.sexp_drop_if Fn.const true]
      }
  | Reg of { initial_value : bool }
  | Regr of { index_of_regt : int }
  | Regt
  | Clock
  | Gnd
  | Vdd
  | External of
      { loc : Loc.t
      ; name : string
      ; method_name : string option
      ; arguments : string list
      ; protocol_prefix : string Set_once.t
      ; index : int Set_once.t
      }
[@@deriving sexp_of]

let pp_debug = function
  | Input -> Pp.verbatim "input"
  | Output -> Pp.verbatim "output"
  | Id -> Pp.verbatim "id"
  | Not -> Pp.verbatim "not"
  | And -> Pp.verbatim "and"
  | Or -> Pp.verbatim "or"
  | Xor -> Pp.verbatim "xor"
  | Mux -> Pp.verbatim "xor"
  | Rom { loc = _; name; index } -> Pp.verbatim (sprintf "rom_%s[%d]" name index)
  | Ram { loc = _; name; address_width = _; data_width = _; contents = _ } ->
    Pp.verbatim (sprintf "ram_%s" name)
  | Reg { initial_value } -> Pp.verbatim (if initial_value then "nreg" else "reg")
  | Regr { index_of_regt } -> Pp.verbatim (sprintf "regr[%d]" index_of_regt)
  | Regt -> Pp.verbatim "regt"
  | Clock -> Pp.verbatim "clock"
  | Gnd -> Pp.verbatim "gnd"
  | Vdd -> Pp.verbatim "vdd"
  | External { loc = _; name; method_name; arguments; protocol_prefix = _; index } ->
    Pp.verbatim
      (sprintf
         "$%s%s%s%s"
         name
         (match method_name with
          | None -> ""
          | Some m -> sprintf ".%s" m)
         (match arguments with
          | [] -> ""
          | _ :: _ ->
            sprintf
              "<%s>"
              (String.concat ~sep:", " (List.map arguments ~f:(sprintf "%S"))))
         (match Set_once.get index with
          | None -> ""
          | Some d -> sprintf "[%d]" d))
;;

module Primitive = struct
  type nonrec t =
    { gate_kind : t
    ; input_width : int
    ; output_width : int
    ; aliases : string list
    }
  [@@deriving sexp_of]

  (* CR mbarbin: This is a transition state, I'd like for it to be a single
     canonical representation for each primitive, and it to be pretty-printed as
     such. In the meantime, several variations are allowed. *)
  let all =
    lazy
      ([ Not, (1, 1), [ "Not"; "not"; "~" ]
       ; And, (2, 1), [ "And"; "and" ]
       ; Or, (2, 1), [ "Or"; "or" ]
       ; Id, (1, 1), [ "Id"; "id" ]
       ; Xor, (2, 1), [ "Xor"; "xor" ]
       ; Mux, (3, 1), [ "Mux"; "mux" ]
       ; Reg { initial_value = false }, (1, 1), [ "Reg"; "reg"; "Z" ]
       ; Reg { initial_value = true }, (1, 1), [ "Reg1"; "nreg"; "nZ" ]
       ; Reg { initial_value = false }, (2, 1), [ "RegEn"; "regen"; "Zen" ]
       ; Reg { initial_value = true }, (2, 1), [ "Reg1En"; "nregen"; "nZen" ]
       ; Clock, (0, 1), [ "Clock"; "clock" ]
       ; Gnd, (0, 1), [ "Gnd"; "gnd" ]
       ; Vdd, (0, 1), [ "Vdd"; "vdd" ]
       ]
       |> List.map ~f:(fun (gate_kind, (input_width, output_width), aliases) ->
         { gate_kind; input_width; output_width; aliases }))
  ;;
end
