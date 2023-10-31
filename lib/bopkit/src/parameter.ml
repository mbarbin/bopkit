module Value = struct
  type t =
    | Int of int
    | String of string
  [@@deriving compare, equal, hash, sexp_of]

  let to_syntax = function
    | Int d -> Int.to_string d
    | String s -> Printf.sprintf "%S" s
  ;;
end

type t =
  { name : string
  ; value : Value.t
  }
[@@deriving equal, sexp_of]

let arg_type =
  let of_string str =
    match String.lsplit2 str ~on:'=' with
    | None -> failwith "Invalid parameter argument. Expected 'name=value'."
    | Some (name, value) ->
      let value : Value.t =
        match Int.of_string_opt value with
        | Some i -> Int i
        | None -> String value
      in
      { name; value }
  in
  Command.Arg_type.create of_string
;;
