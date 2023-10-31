type 'a t = ('a, Eval_error.t) Result.t [@@deriving sexp_of]

include Applicative.S with type 'a t := 'a t
include Monad.S with type 'a t := 'a t

val with_return : (error:Eval_error.t With_return.return -> 'a) -> 'a t
val propagate : error:Eval_error.t With_return.return -> 'a t -> 'a
val ok : 'a t -> f:(Eval_error.t -> 'a) -> 'a
val ok_exn : 'a t -> error_log:Error_log.t -> loc:Loc.t -> 'a
