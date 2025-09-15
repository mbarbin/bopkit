(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Operation_kind = struct
  type t =
    | Macro_call of { macro_name : Macro_name.t }
    | Instruction of { instruction_name : Instruction_name.t }
  [@@deriving equal, sexp_of]
end

module Argument = struct
  type t =
    (* $MDX part-begin=arguments *)
    | Value of { value : int }
    | Address of { address : Address.t }
    | Constant of { constant_name : Constant_name.t }
    | Label of { label : Label.t }
    | Register of { register_name : Register_name.t }
    | Parameter of { parameter_name : Parameter_name.t } (* $MDX part-end *)
  [@@deriving equal, sexp_of]

  let to_string = function
    | Value { value } -> Printf.sprintf "#%d" value
    | Address { address } -> Address.to_string address
    | Constant { constant_name } -> Constant_name.to_string constant_name
    | Label { label } -> Printf.sprintf "@%s" (Label.to_string label)
    | Register { register_name } -> Register_name.to_string register_name
    | Parameter { parameter_name } ->
      Printf.sprintf "$%s" (Parameter_name.to_string parameter_name)
  ;;
end

type t =
  { loc : Loc.t
  ; operation_kind : Operation_kind.t
  ; arguments : Argument.t Loc.Txt.t list
  }
[@@deriving equal, sexp_of]

let to_string { loc = _; operation_kind; arguments } =
  let operator =
    match operation_kind with
    | Macro_call { macro_name } -> Macro_name.to_string macro_name
    | Instruction { instruction_name } -> Instruction_name.to_string instruction_name
  in
  let arguments = List.map arguments ~f:(fun t -> Argument.to_string t.txt) in
  match arguments with
  | [] -> operator
  | _ :: _ -> String.concat [ operator; String.concat arguments ~sep:", " ] ~sep:" "
;;
