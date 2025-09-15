(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

module Node : sig
  type t =
    { output : Ident.t
    ; muxtree : Muxtree.t
    }
  [@@deriving sexp_of]
end

type t = Node.t list [@@deriving sexp_of]

val of_muxtrees : Muxtree.t list -> t
