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

let param =
  let parse str =
    match String.lsplit2 str ~on:'=' with
    | None -> Error (`Msg "Invalid parameter argument. Expected 'name=value'.")
    | Some (name, value) ->
      let value : Value.t =
        match Int.of_string_opt value with
        | Some i -> Int i
        | None -> String value
      in
      Ok { name; value }
  in
  let print fmt { name; value } =
    Stdlib.Format.fprintf fmt "%s=%s" name (Value.to_syntax value)
  in
  Command.Param.create ~docv:"name=value" ~parse ~print
;;
