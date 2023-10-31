type 'a t = ('a, Eval_error.t) Result.t [@@deriving sexp_of]

let return a = Ok a
let map t ~f = Result.map t ~f
let bind t ~f = Result.bind t ~f

include Applicative.Make (struct
    type nonrec 'a t = 'a t

    let return = return
    let apply f x = Result.combine f x ~ok:(fun f x -> f x) ~err:(fun e1 _ -> e1)
    let map = `Custom map
  end)

include Monad.Make (struct
    type nonrec 'a t = 'a t

    let return = return
    let bind = bind
    let map = `Custom map
  end)

let with_return f =
  With_return.with_return (fun return ->
    Ok (f ~error:(With_return.prepend return ~f:(fun e -> Error e))))
;;

let propagate ~(error : _ With_return.return) = function
  | Ok e -> e
  | Error e -> error.return e
;;

let ok t ~f =
  match t with
  | Ok e -> e
  | Error e -> f e
;;

let ok_exn t ~error_log ~loc =
  match t with
  | Ok e -> e
  | Error e -> Eval_error.raise e ~error_log ~loc
;;
