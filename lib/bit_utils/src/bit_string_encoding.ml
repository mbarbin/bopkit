(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Bit = struct
  type t = bool

  let of_char = function
    | '1' -> true
    | _ -> false
  ;;

  let to_char = function
    | true -> '1'
    | false -> '0'
  ;;
end

module Bit_option = struct
  type t = bool option

  let of_char = function
    | '1' -> Some true
    | '*' -> None
    | _ -> Some false
  ;;

  let to_char = function
    | Some true -> '1'
    | Some false -> '0'
    | None -> '*'
  ;;
end
