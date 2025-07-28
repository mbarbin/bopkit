type t = Parameter.t list

let find (t : t) ~parameter_name =
  List.find_map t ~f:(fun p ->
    Option.some_if (String.equal p.name parameter_name) p.value)
;;

let mem (t : t) ~parameter_name =
  List.exists t ~f:(fun p -> String.equal p.name parameter_name)
;;

let keys (t : t) =
  let present = Hash_set.create (module String) in
  List.filter_map t ~f:(fun p ->
    let name = p.name in
    if Hash_set.mem present name
    then None
    else (
      Hash_set.add present name;
      Some name))
;;

let overrides =
  let%map_open.Command overrides =
    Arg.named_multi [ "parameter" ] Parameter.param ~doc:"Override parameter."
  in
  overrides
;;
