(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

open! Base

module Method_kind : sig
  type t =
    | Main
    | Named of
        { method_name : string
        ; arguments : string list
        }
  [@@deriving sexp_of]
end

type t =
  { method_kind : Method_kind.t
  ; bits : string
  }
[@@deriving sexp_of]
