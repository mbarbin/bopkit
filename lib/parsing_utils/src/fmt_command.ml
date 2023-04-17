open! Core
open! Or_error.Let_syntax

(* Because of blank lines that appears in boxes are indented and produce
   trailing whitespace, we post-process the result of the pretty printing. *)
let pp_to_string pp =
  let buffer = Buffer.create 23 in
  let formatter = Format.formatter_of_buffer buffer in
  Format.fprintf formatter "%a%!" Pp.to_fmt pp;
  let contents =
    Buffer.contents buffer
    |> String.split_lines
    |> List.map ~f:(fun s -> String.rstrip s ^ "\n")
    |> String.concat
  in
  contents
;;

let find_files_in_cwd_by_extensions ~extensions =
  let ls_dir =
    Sys_unix.readdir (Sys_unix.getcwd ())
    |> Array.to_list
    |> List.sort ~compare:String.compare
  in
  List.filter ls_dir ~f:(fun file ->
    Sys_unix.is_file_exn ~follow_symlinks:true file
    && List.exists extensions ~f:(fun extension -> Filename.check_suffix file extension))
;;

let bopkit_force_fmt =
  lazy
    (let var = "BOPKIT_FORCE_FMT" in
     match Sys.getenv var with
     | Some "true" -> true
     | None | Some "false" -> false
     | Some value ->
       raise_s
         [%sexp "Unexpected value for env var", [%here], { var : string; value : string }])
;;

module type T = sig
  type t [@@deriving equal, sexp_of]
end

module type T_pp = sig
  type t

  val pp : t -> unit Pp.t
end

module Make
  (T : T)
  (T_syntax : Parsing_utils.S with type t = T.t)
  (T_pp : T_pp with type t = T.t) =
struct
  module Pretty_print_result = struct
    type t =
      { pretty_printed_contents : string
      ; result : unit Or_error.t
      }
  end

  let pretty_print ~filename ~read_contents_from_stdin =
    let force = force bopkit_force_fmt in
    let stdin_contents =
      if read_contents_from_stdin then In_channel.input_all In_channel.stdin else ""
    in
    let rec find_fixpoint ~num_steps ~filename =
      let original_contents =
        if read_contents_from_stdin && num_steps = 0
        then stdin_contents
        else In_channel.read_all filename
      in
      let%bind (program : T.t) =
        if read_contents_from_stdin && num_steps = 0
        then
          Parsing_utils.parse_lexbuf
            (module T_syntax)
            ~filename
            ~lexbuf:(Lexing.from_string stdin_contents)
        else Parsing_utils.parse_file (module T_syntax) ~filename
      in
      let temp_file, oc = Filename_unix.open_temp_file "fmt_command" "fixpoint" in
      Out_channel.output_string oc (pp_to_string (T_pp.pp program));
      Out_channel.flush oc;
      Out_channel.close oc;
      let pretty_printed_contents = In_channel.read_all temp_file in
      let ts_are_equal =
        let%map (program_2 : T.t) =
          Parsing_utils.parse_file (module T_syntax) ~filename:temp_file
        in
        Ref.set_temporarily Loc.equal_ignores_positions true ~f:(fun () ->
          T.equal program program_2)
      in
      let result =
        let ts_are_equal =
          match ts_are_equal with
          | Ok false -> if force then Ok true else ts_are_equal
          | t -> t
        in
        match ts_are_equal with
        | Ok false ->
          return
            { Pretty_print_result.pretty_printed_contents
            ; result = Or_error.error_s [%sexp "AST changed during pretty-printing"]
            }
        | Error e ->
          return
            { Pretty_print_result.pretty_printed_contents
            ; result =
                Or_error.error_s
                  [%sexp "Pretty-printing produced invalid syntax", (e : Error.t)]
            }
        | Ok true ->
          if String.equal pretty_printed_contents original_contents
          then return { Pretty_print_result.pretty_printed_contents; result = Ok () }
          else find_fixpoint ~num_steps:(succ num_steps) ~filename:temp_file
      in
      Core_unix.unlink temp_file;
      result
    in
    find_fixpoint ~num_steps:0 ~filename
  ;;

  let test_cmd =
    Command.basic
      ~summary:"check that all files of the current directory can be pretty-printed"
      (let open Command.Let_syntax in
       let%map_open extensions = anon (".EXT" %: string |> non_empty_sequence_as_list) in
       fun () ->
         let files = find_files_in_cwd_by_extensions ~extensions in
         List.iter files ~f:(fun filename ->
           print_endline (sprintf "================================: %s" filename);
           match pretty_print ~filename ~read_contents_from_stdin:false with
           | Error e -> print_endline (Error.to_string_hum e)
           | Ok { pretty_printed_contents; result } ->
             print_string pretty_printed_contents;
             (match result with
              | Ok () -> ()
              | Error e ->
                print_endline "======: errors";
                print_endline (Error.to_string_hum e))))
  ;;

  let gen_dune_cmd =
    Command.basic
      ~summary:
        "generate dune stanza for all files present in the cwd to be pretty-printed"
      (let open Command.Let_syntax in
       let%map_open extensions = anon (".EXT" %: string |> non_empty_sequence_as_list)
       and call =
         flag "--" escape ~doc:" how to access the [fmt file] command for these files"
         >>| Option.value ~default:[]
       in
       fun () ->
         let files = find_files_in_cwd_by_extensions ~extensions in
         let output_ext = ".pp.output" in
         let generate_rules ~file =
           let open Sexp in
           let list s = List s
           and atom s = Atom s in
           let atoms s = List.map s ~f:atom in
           let pp =
             list
               [ atom "rule"
               ; list
                   [ atom "with-stdout-to"
                   ; atom (file ^ output_ext)
                   ; list
                       [ atom "bash"
                       ; atom (String.concat ~sep:" " call ^ sprintf " %%{dep:%s}" file)
                       ]
                   ]
               ]
           in
           let fmt =
             list
               [ atom "rule"
               ; list (atoms [ "alias"; "fmt" ])
               ; list
                   [ atom "action"
                   ; list [ atom "diff"; atom file; atom (file ^ output_ext) ]
                   ]
               ]
           in
           [ pp; fmt ]
         in
         Printf.printf
           "; dune file generated by '%s' -- do not edit.\n"
           (List.map call ~f:(function
              | "file" -> "gen-dune"
              | e -> e)
            |> String.concat ~sep:" ");
         List.iter files ~f:(fun file ->
           List.iter (generate_rules ~file) ~f:(fun sexp ->
             print_endline (Sexp.to_string_hum sexp))))
  ;;

  let file_cmd =
    Command.basic
      ~summary:"autoformat a bopkit file"
      ~readme:(fun () ->
        {|
This is a pretty-print command for bopkit files (extension *.bop).

This reads the contents of a bopkit file supplied in the command line, and
pretty-print it on stdout, leaving the original file unchanged.

If [-read-contents-from-stdin] is supplied, then the contents of the file is
read from stdin. In this case the filename must still be supplied, and will be
used for located error messages only.

In case of syntax errors or other issues, some contents may still be printed
to stdout, however the exit code will be non zero (typically [1]). Errors are
printed on stderr.

The hope for this command is for it to be compatible with editors and build
systems so that you can integrate autoformatting of bopkit files into your
workflow.

It is used by [dune fmt] throughout the bopkit project, and has been tested
with vscode. Because this command has been tested with a vscode extension that
strips the last newline, a flag has been added to add an extra blank line,
shall you run into this issue.
      |})
      (let open Command.Let_syntax in
       let%map_open filename = anon ("FILE" %: string)
       and read_contents_from_stdin =
         flag
           "read-contents-from-stdin"
           no_arg
           ~doc:" read contents from stdin rather than from the file"
       and add_extra_blank_line =
         flag "add-extra-blank-line" no_arg ~doc:" add an extra blank line at the end"
       in
       fun () ->
         let open Or_error.Let_syntax in
         match
           let%bind { Pretty_print_result.pretty_printed_contents; result } =
             pretty_print ~filename ~read_contents_from_stdin
           in
           print_string pretty_printed_contents;
           if add_extra_blank_line then print_endline "";
           Out_channel.flush stdout;
           result
         with
         | Ok () -> ()
         | Error e ->
           prerr_endline (Error.to_string_hum e);
           exit 1)
  ;;

  let dump_cmd =
    Command.basic
      ~summary:"dump a parsed tree on stdout"
      (let open Command.Let_syntax in
       let%map_open filename = anon ("FILE" %: string)
       and with_positions = flag "-loc" no_arg ~doc:" dump loc details"
       and debug_comments =
         flag "-debug-comments" no_arg ~doc:" dump comments state messages"
       in
       fun () ->
         match
           let open Or_error.Let_syntax in
           let%bind (program : T.t) =
             Ref.set_temporarily Comments_state.debug debug_comments ~f:(fun () ->
               Parsing_utils.parse_file (module T_syntax) ~filename)
           in
           Ref.set_temporarily Loc.include_sexp_of_positions with_positions ~f:(fun () ->
             print_s [%sexp (program : T.t)]);
           Out_channel.flush stdout;
           return ()
         with
         | Ok () -> ()
         | Error e ->
           prerr_endline (Error.to_string_hum e);
           exit 1)
  ;;

  let fmt_cmd =
    Command.group
      ~summary:"commands related to auto-formatting"
      [ "dump", dump_cmd; "file", file_cmd; "test", test_cmd; "gen-dune", gen_dune_cmd ]
  ;;
end

let fmt_cmd
  (type t)
  (module T : T with type t = t)
  (module Syntax : Parsing_utils.S with type t = t)
  (module Pp : T_pp with type t = t)
  =
  let module M = Make (T) (Syntax) (Pp) in
  M.fmt_cmd
;;
