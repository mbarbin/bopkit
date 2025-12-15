(*_********************************************************************************)
(*_  bopkit: An educational project for digital circuits programming              *)
(*_  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

type 'a t = ('a, Eval_error.t) Result.t [@@deriving sexp_of]

include Applicative.S with type 'a t := 'a t
include Monad.S with type 'a t := 'a t

val ok : 'a t -> f:(Eval_error.t -> 'a) -> 'a
val ok_exn : 'a t -> loc:Loc.t -> 'a
