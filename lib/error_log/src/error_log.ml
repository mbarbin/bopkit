open! Or_error.Let_syntax
module Style = Stdune.User_message.Style

module Config = struct
  module Mode = struct
    type t =
      | Quiet
      | Default
      | Verbose
      | Debug
    [@@deriving compare, equal, enumerate, sexp_of]
  end

  type t = { mode : Mode.t } [@@deriving equal, sexp_of]

  let default = { mode = Default }

  let param =
    let open Command.Let_syntax in
    let%map_open mode =
      let verbose =
        if%map flag "verbose" ~aliases:[ "v" ] no_arg ~doc:" print more messages"
        then Some Mode.Verbose
        else None
      and debug =
        if%map flag "debug" no_arg ~doc:" enable all messages including debug output"
        then Some Mode.Debug
        else None
      and quiet =
        if%map flag "quiet" ~aliases:[ "q" ] no_arg ~doc:" suppress output except errors"
        then Some Mode.Quiet
        else None
      in
      choose_one [ debug; verbose; quiet ] ~if_nothing_chosen:(Default_to Mode.Default)
    in
    { mode }
  ;;
end

(* I've tried testing the following, which doesn't work as expected:

   {v
   let%expect_test "am_running_test" =
     print_s [%sexp { am_running_inline_test : bool; am_running_test : bool }];
     [%expect {| ((am_running_inline_test false) (am_running_test false)) |}];
     ()
   ;;
   v}

   Thus been using this variable to avoid the printer to produce styles in expect
   tests when running in the GitHub Actions environment.
*)
let force_am_running_test = ref false

module Message = struct
  module Kind = struct
    type t =
      | Error
      | Warning
      | Info
      | Debug
    [@@deriving equal, equal, sexp_of]

    let is_printed t ~(config : Config.t) =
      match (t : t) with
      | Error -> true
      | Warning -> Config.Mode.compare config.mode Default >= 0
      | Info -> Config.Mode.compare config.mode Verbose >= 0
      | Debug -> Config.Mode.compare config.mode Debug >= 0
    ;;
  end

  type message = Stdune.User_message.t

  let sexp_of_message _ = Sexp.Atom "<opaque>"

  type t =
    { kind : Kind.t
    ; message : message
    ; mutable flushed : bool
    }
  [@@deriving sexp_of]

  let test_printer pp =
    let ppf = Stdlib.Format.err_formatter in
    Pp.to_fmt ppf pp;
    Stdlib.Format.pp_print_flush ppf ()
  ;;

  let print (t : t) ~config =
    if not t.flushed
    then (
      if Kind.is_printed t.kind ~config
      then (
        let use_test_printer = !force_am_running_test in
        Option.iter t.message.loc ~f:(fun loc ->
          (if use_test_printer then test_printer else Stdune.Ansi_color.prerr)
            (Stdune.Loc.pp loc
             |> Pp.map_tags ~f:(fun Loc -> Stdune.User_message.Print_config.default Loc)));
        let message = { t.message with loc = None } in
        if use_test_printer
        then test_printer (Stdune.User_message.pp message)
        else Stdune.User_message.prerr message);
      t.flushed <- true)
  ;;
end

type t =
  { config : Config.t
  ; messages : Message.t Queue.t
  }
[@@deriving sexp_of]

exception Fatal_error

let create ~config = { config; messages = Queue.create () }
let did_you_mean = Stdune.User_message.did_you_mean

let raise t ?loc ?hints paragraphs =
  let message = Stdune.User_error.make ?loc ?hints paragraphs in
  Queue.enqueue t.messages { kind = Error; message; flushed = false };
  raise Fatal_error
;;

let error t ?loc ?hints paragraphs =
  let message = Stdune.User_error.make ?loc ?hints paragraphs in
  Queue.enqueue t.messages { kind = Error; message; flushed = false }
;;

let warning t ?loc ?hints paragraphs =
  let message =
    let open Stdune in
    User_message.make
      ?loc
      ?hints
      ~prefix:
        (Pp.seq (Pp.tag User_message.Style.Warning (Pp.verbatim "Warning")) (Pp.char ':'))
      paragraphs
  in
  Queue.enqueue t.messages { kind = Warning; message; flushed = false }
;;

let info t ?loc ?hints paragraphs =
  let message =
    let open Stdune in
    User_message.make
      ?loc
      ?hints
      ~prefix:(Pp.seq (Pp.tag User_message.Style.Kwd (Pp.verbatim "Info")) (Pp.char ':'))
      paragraphs
  in
  Queue.enqueue t.messages { kind = Info; message; flushed = false }
;;

let debug t ?loc ?hints paragraphs =
  let message =
    let open Stdune in
    User_message.make
      ?loc
      ?hints
      ~prefix:
        (Pp.seq (Pp.tag User_message.Style.Debug (Pp.verbatim "Debug")) (Pp.char ':'))
      paragraphs
  in
  Queue.enqueue t.messages { kind = Debug; message; flushed = false }
;;

let special_error = Error.of_string "Aborted due to errors previously reported."

let flush { config; messages } =
  Queue.iter messages ~f:(fun message -> Message.print message ~config)
;;

let has_errors t =
  Queue.exists t.messages ~f:(fun t ->
    match t.kind with
    | Error -> true
    | Warning | Info | Debug -> false)
;;

let checkpoint (t : t) = if has_errors t then Error special_error else Ok ()
let mode t = t.config.mode
let is_debug_mode t = Config.Mode.equal (mode t) Debug

let report_and_return_status ?(config = Config.default) f () =
  let t = create ~config in
  let status =
    match f t with
    | Ok () -> if has_errors t then `Fatal_error else `Ok
    | Error e -> `Error e
    | exception Fatal_error -> `Fatal_error
    | exception e ->
      let raw_backtrace = Stdlib.Printexc.get_raw_backtrace () in
      `Raised (e, raw_backtrace)
  in
  flush t;
  match status with
  | (`Ok | `Raised _) as status -> status
  | `Fatal_error -> `Error
  | `Error e ->
    if not (phys_equal e special_error) then prerr_endline (Error.to_string_hum e);
    `Error
;;

let report_and_exit ~config f () =
  match report_and_return_status ~config f () with
  | `Ok -> Stdlib.exit 0
  | `Error -> Stdlib.exit 1
  | `Raised (e, raw_backtrace) -> Stdlib.Printexc.raise_with_backtrace e raw_backtrace
;;

module For_test = struct
  let report ?config f =
    match
      Ref.set_temporarily force_am_running_test true ~f:(fun () ->
        report_and_return_status ?config f ())
    with
    | `Ok -> ()
    | `Error -> prerr_endline "[1]"
    | `Raised (e, raw_backtrace) -> Stdlib.Printexc.raise_with_backtrace e raw_backtrace
  ;;
end
