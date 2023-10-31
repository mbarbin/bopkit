module Part = struct
  type t =
    | Text of string
    | Var of string
  [@@deriving equal, sexp_of]
end

module Parts = struct
  type t = { parts : Part.t list } [@@deriving sexp_of]
end

type t = Parts.t = { parts : Part.t list } [@@deriving equal]

module Syntax = struct
  (* During a transition period, we support both syntaxes. At some
     point the dollar one will be retired. *)
  type t =
    | Dollar
    | Percent

  let start = function
    | Dollar -> '$'
    | Percent -> '%'
  ;;

  let open_char = function
    | Dollar -> '('
    | Percent -> '{'
  ;;

  let close_char = function
    | Dollar -> ')'
    | Percent -> '}'
  ;;
end

let parse t =
  Or_eval_error.with_return (fun ~error ->
    let len_t = String.length t in
    let bounds = Queue.create () in
    let rec enqueue offset len ~is_parsing_var i =
      match is_parsing_var with
      | Some syntax ->
        if i >= len_t
        then error.return (Syntax_error { in_ = t })
        else if Char.equal t.[i] (Syntax.close_char syntax)
        then (
          Queue.enqueue bounds (offset, len);
          enqueue 0 0 ~is_parsing_var:None (succ i))
        else enqueue offset (succ len) ~is_parsing_var (succ i)
      | None ->
        if i >= len_t
        then ()
        else (
          match
            if Char.equal t.[i] '$'
               && i <= len_t - 2
               && Char.( = ) t.[succ i] (Syntax.open_char Dollar)
            then Some Syntax.Dollar
            else if Char.equal t.[i] '%'
                    && i <= len_t - 2
                    && Char.( = ) t.[succ i] (Syntax.open_char Percent)
            then Some Syntax.Percent
            else None
          with
          | Some syntax ->
            if i >= len_t - 3
            then error.return (Syntax_error { in_ = t })
            else enqueue i 3 ~is_parsing_var:(Some syntax) (i + 2)
          | None -> enqueue 0 0 ~is_parsing_var:None (succ i))
    in
    let parts : Part.t Queue.t = Queue.create () in
    let rec dequeue b =
      match Queue.dequeue bounds with
      | None ->
        if b < len_t
        then Queue.enqueue parts (Text (String.sub t ~pos:b ~len:(len_t - b)))
      | Some (offset, len) ->
        if b < offset
        then Queue.enqueue parts (Text (String.sub t ~pos:b ~len:(offset - b)));
        Queue.enqueue parts (Var (String.sub t ~pos:(offset + 2) ~len:(len - 3)));
        dequeue (offset + len)
    in
    enqueue 0 0 ~is_parsing_var:None 0;
    dequeue 0;
    { parts = Queue.to_list parts })
;;

let to_string ?(syntax = Syntax.Dollar) { parts } =
  List.map parts ~f:(function
    | Text text -> text
    | Var var ->
      sprintf
        "%c%c%s%c"
        (Syntax.start syntax)
        (Syntax.open_char syntax)
        var
        (Syntax.close_char syntax))
  |> String.concat
;;

let sexp_of_t t = Sexp.Atom (to_string t)

let string_of_var ~parameters v =
  Or_eval_error.with_return (fun ~error ->
    match Parameters.find parameters ~parameter_name:v with
    | Some (Parameter.Value.Int i) -> string_of_int i
    | Some (Parameter.Value.String s) -> s
    | None ->
      error.return (Free_variable { name = v; candidates = Parameters.keys parameters }))
;;

let eval (t : t) ~parameters =
  Or_eval_error.with_return (fun ~error ->
    let find_value v = string_of_var ~parameters v |> Or_eval_error.propagate ~error in
    List.map t.parts ~f:(function
      | Text text -> text
      | Var var -> find_value var)
    |> String.concat)
;;

let vars (t : t) =
  List.filter_map t.parts ~f:(function
    | Text _ -> None
    | Var var -> Some var)
  |> Appendable_list.of_list
;;

module Private = struct
  module Part = Part

  let to_parts (t : t) = t.parts
end
