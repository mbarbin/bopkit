open! Or_error.Let_syntax

let find_distribution_file ~path ~loc ~error_log =
  Bopkit_sites.Sites.stdlib
  |> List.find_map ~f:(fun stdlib_directory ->
    let rfile = Filename.concat stdlib_directory (path |> Fpath.to_string) in
    if Sys_unix.file_exists_exn rfile then Some rfile else None)
  |> function
  | Some rfile -> rfile |> Fpath.v
  | None ->
    Error_log.raise
      error_log
      ~loc
      [ Pp.textf "%S: included file not found." (path |> Fpath.to_string) ]
      ~hints:
        [ Pp.textf
            "Try running `bopkit print-sites` to locate and inspect the directory where \
             the stdlib files are installed on your machine."
        ]
;;

(* CR mbarbin: Currently this logic uses the notion of module_name_of_path to
   avoid including files multiple times. I would like to change this to a more
   straight-forward mechanism, perhaps using simply the basename. TBD. *)

let module_name_of_path ~path:f =
  f |> Fpath.rem_ext |> Fpath.filename |> String.capitalize
;;

let pass ~path ~error_log =
  let netlists : Standalone_netlist.t Stack.t = Stack.create () in
  let included_modules = Hash_set.create (module String) in
  let rec include_file ~loc ~path =
    let module_name = module_name_of_path ~path in
    if not (Hash_set.mem included_modules module_name)
    then (
      Error_log.debug
        error_log
        ~loc
        [ Pp.textf "--> #include file = %S" (path |> Fpath.to_string) ];
      let { Bopkit.Netlist.include_files
          ; parameters
          ; memories
          ; external_blocks
          ; blocks
          ; eof_comments = _
          }
        =
        Parsing_utils.parse_file_exn (module Bopkit_syntax) ~path ~error_log
      in
      Hash_set.add included_modules module_name;
      Stack.push
        netlists
        { paths = [ path ]; parameters; memories; external_blocks; blocks };
      List.iter include_files ~f:(fun { loc; comments = _; include_file_kind } ->
        match include_file_kind with
        | File_path path -> include_file ~loc ~path
        | Distribution { file = path; file_is_quoted = _ } ->
          include_distribution_file ~loc ~path))
  and include_distribution_file ~loc ~path =
    let module_name = module_name_of_path ~path in
    if not (Hash_set.mem included_modules module_name)
    then (
      let path = find_distribution_file ~path ~loc ~error_log in
      include_file ~loc ~path)
  in
  include_file ~loc:(Loc.in_file ~path) ~path;
  Standalone_netlist.concat (Stack.to_list netlists)
;;
