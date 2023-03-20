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
