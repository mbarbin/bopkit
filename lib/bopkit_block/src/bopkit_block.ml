open! Base
open! Stdio
open! Or_error.Let_syntax

module Arity = struct
  type ('kind, 'signal) t =
    | Empty : (unit, 'signal) t
    | Signal : ('signal, 'signal) t
    | Bus : { width : int } -> (bool array, 'signal) t
    | Remaining_bits : (bool array, bool) t
    | Output_buffer : (Buffer.t, bool ref) t
    | Tuple_2 :
        (('kind1, 'signal) t * ('kind2, 'signal) t)
        -> ('kind1 * 'kind2, 'signal) t
    | Tuple_3 :
        (('kind1, 'signal) t * ('kind2, 'signal) t * ('kind3, 'signal) t)
        -> ('kind1 * 'kind2 * 'kind3, 'signal) t
    | Tuple_4 :
        (('kind1, 'signal) t
        * ('kind2, 'signal) t
        * ('kind3, 'signal) t
        * ('kind4, 'signal) t)
        -> ('kind1 * 'kind2 * 'kind3 * 'kind4, 'signal) t
    | Tuple_5 :
        (('kind1, 'signal) t
        * ('kind2, 'signal) t
        * ('kind3, 'signal) t
        * ('kind4, 'signal) t
        * ('kind5, 'signal) t)
        -> ('kind1 * 'kind2 * 'kind3 * 'kind4 * 'kind5, 'signal) t
    | Tuple_6 :
        (('kind1, 'signal) t
        * ('kind2, 'signal) t
        * ('kind3, 'signal) t
        * ('kind4, 'signal) t
        * ('kind5, 'signal) t
        * ('kind6, 'signal) t)
        -> ('kind1 * 'kind2 * 'kind3 * 'kind4 * 'kind5 * 'kind6, 'signal) t

  let check_read_bits_exn ~input ~from ~len =
    let line_length = Array.length input in
    if line_length < from + len
    then
      raise_s
        [%sexp
          "input line is too short"
          , { line_length : int; needs_next_input = { from : int; len : int } }]
  ;;

  let rec read_input : type a. bool array -> index:int ref -> (a, bool) t -> a =
    fun input ~index arity ->
    match arity with
    | Empty -> ()
    | Signal ->
      check_read_bits_exn ~input ~from:!index ~len:1;
      let i = input.(!index) in
      Int.incr index;
      i
    | Bus { width } ->
      check_read_bits_exn ~input ~from:!index ~len:width;
      let array = Array.create ~len:width false in
      Array.blit ~src:input ~src_pos:!index ~dst:array ~dst_pos:0 ~len:width;
      index := !index + width;
      array
    | Remaining_bits ->
      let width = Array.length input - !index in
      read_input input ~index (Bus { width })
    | Tuple_2 (a, b) ->
      let a = read_input input ~index a in
      let b = read_input input ~index b in
      a, b
    | Tuple_3 (a, b, c) ->
      let a = read_input input ~index a in
      let b = read_input input ~index b in
      let c = read_input input ~index c in
      a, b, c
    | Tuple_4 (a, b, c, d) ->
      let a = read_input input ~index a in
      let b = read_input input ~index b in
      let c = read_input input ~index c in
      let d = read_input input ~index d in
      a, b, c, d
    | Tuple_5 (a, b, c, d, e) ->
      let a = read_input input ~index a in
      let b = read_input input ~index b in
      let c = read_input input ~index c in
      let d = read_input input ~index d in
      let e = read_input input ~index e in
      a, b, c, d, e
    | Tuple_6 (a, b, c, d, e, f) ->
      let a = read_input input ~index a in
      let b = read_input input ~index b in
      let c = read_input input ~index c in
      let d = read_input input ~index d in
      let e = read_input input ~index e in
      let f = read_input input ~index f in
      a, b, c, d, e, f
  ;;
end

module Method = struct
  module Expert = struct
    module Kind = struct
      type 'arguments t =
        | Main : unit t
        | Named : { method_name : string } -> string list t
    end

    type 'arguments t =
      | T :
          { kind : 'arguments Kind.t
          ; input_arity : ('input, bool) Arity.t
          ; output_arity : ('output, bool ref) Arity.t
          ; f : arguments:'arguments -> input:'input -> output:'output -> unit
          }
          -> 'arguments t

    let create ~kind ~input_arity ~output_arity ~f =
      T { kind; input_arity; output_arity; f }
    ;;
  end

  type 'a t = 'a Expert.t

  let main ~input_arity ~output_arity ~f =
    Expert.create
      ~kind:Main
      ~input_arity
      ~output_arity
      ~f:(fun ~arguments:() ~input ~output -> f ~input ~output)
  ;;

  let create ~name ~input_arity ~output_arity ~f =
    Expert.create ~kind:(Named { method_name = name }) ~input_arity ~output_arity ~f
  ;;
end

let rec create_output : type kind. (kind, bool ref) Arity.t -> kind = function
  | Empty -> ()
  | Signal -> ref false
  | Bus { width } -> Array.create ~len:width false
  | Output_buffer -> Buffer.create 23
  | Tuple_2 (a, b) ->
    let a = create_output a in
    let b = create_output b in
    a, b
  | Tuple_3 (a, b, c) ->
    let a = create_output a in
    let b = create_output b in
    let c = create_output c in
    a, b, c
  | Tuple_4 (a, b, c, d) ->
    let a = create_output a in
    let b = create_output b in
    let c = create_output c in
    let d = create_output d in
    a, b, c, d
  | Tuple_5 (a, b, c, d, e) ->
    let a = create_output a in
    let b = create_output b in
    let c = create_output c in
    let d = create_output d in
    let e = create_output e in
    a, b, c, d, e
  | Tuple_6 (a, b, c, d, e, f) ->
    let a = create_output a in
    let b = create_output b in
    let c = create_output c in
    let d = create_output d in
    let e = create_output e in
    let f = create_output f in
    a, b, c, d, e, f
;;

let create_input : type kind. (kind, bool) Arity.t -> line:string -> kind =
  fun arity ~line ->
  let bool_of_char = Bit_string_encoding.Bit.of_char in
  let input = Array.init (String.length line) ~f:(fun i -> bool_of_char line.[i]) in
  let index = ref 0 in
  Arity.read_input input ~index arity
;;

module Context = struct
  type t =
    { name : string
    ; index_cycle : int ref
    }
  [@@deriving sexp_of]
end

let run_line
  (type arguments)
  (Method.Expert.T t : arguments Method.t)
  ~context
  ~no_output
  ~(arguments : arguments)
  ~line
  =
  let output = create_output t.output_arity in
  let%map () =
    try
      let input = create_input t.input_arity ~line in
      t.f ~arguments ~input ~output;
      Ok ()
    with
    | e ->
      Or_error.error_s
        [%sexp
          "External block exception"
          , (context : Context.t)
          , { line : string }
          , (e : Exn.t)]
  in
  let buffer = Buffer.create 23 in
  let fff c = Buffer.add_char buffer (Bit_string_encoding.Bit.to_char c) in
  let rec iter_output : type a. (a, bool ref) Arity.t -> a -> unit =
    fun arity output ->
    match arity with
    | Empty -> ()
    | Signal -> fff !output
    | Bus { width = _ } -> Array.iter output ~f:fff
    | Output_buffer -> Buffer.add_string buffer (Buffer.contents output)
    | Tuple_2 (ta, tb) ->
      let a, b = output in
      iter_output ta a;
      iter_output tb b
    | Tuple_3 (ta, tb, tc) ->
      let a, b, c = output in
      iter_output ta a;
      iter_output tb b;
      iter_output tc c
    | Tuple_4 (ta, tb, tc, td) ->
      let a, b, c, d = output in
      iter_output ta a;
      iter_output tb b;
      iter_output tc c;
      iter_output td d
    | Tuple_5 (ta, tb, tc, td, te) ->
      let a, b, c, d, e = output in
      iter_output ta a;
      iter_output tb b;
      iter_output tc c;
      iter_output td d;
      iter_output te e
    | Tuple_6 (ta, tb, tc, td, te, tf) ->
      let a, b, c, d, e, f = output in
      iter_output ta a;
      iter_output tb b;
      iter_output tc c;
      iter_output td d;
      iter_output te e;
      iter_output tf f
  in
  iter_output t.output_arity output;
  if not no_output then print_endline (Buffer.contents buffer)
;;

type t =
  { name : string
  ; main : unit Method.t
  ; methods : string list Method.t list
  ; is_multi_threaded : bool
  }

let create ~name ~main ?(methods = []) ?(is_multi_threaded = false) () =
  { name; main; methods; is_multi_threaded }
;;

let main ?readme t_param =
  Command.make
    ~summary:"external block"
    ?readme
    (let%map_open.Command _verbose = Arg.flag [ "verbose" ] ~doc:"be more verbose"
     and stop_at_cycle = Arg.named_opt [ "c" ] Param.int ~docv:"N" ~doc:"stop at cycle N"
     and no_input = Arg.flag [ "no-input"; "ni" ] ~doc:"block will read no input"
     and no_output = Arg.flag [ "no-output"; "no" ] ~doc:"block will print no output"
     and { name; main; methods; is_multi_threaded } = t_param in
     let index_cycle = ref 0 in
     let context = { Context.name; index_cycle } in
     let run_line input =
       let open Or_error.Let_syntax in
       let%bind (protocol : Protocol.t) =
         match Parser.protocol Lexer.read (Lexing.from_string input) with
         | protocol -> Ok protocol
         | exception e ->
           Or_error.error_s
             [%sexp
               "parsing error"
               , [%here]
               , { context : Context.t; input : string }
               , (e : Exn.t)]
       in
       let line = protocol.bits in
       match protocol.method_kind with
       | Main -> run_line main ~context ~no_output ~arguments:() ~line
       | Named { method_name; arguments } ->
         (match
            List.find methods ~f:(fun (T t) ->
              match t.kind with
              | Named { method_name = method_name' } ->
                String.equal method_name method_name')
          with
          | Some t -> run_line t ~context ~no_output ~arguments ~line
          | None ->
            Or_error.error_s
              [%sexp "method not found", (context : Context.t), { method_name : string }])
     in
     let stop_at_cycle = Option.value stop_at_cycle ~default:(-1) in
     With_return.with_return (fun { return } ->
       while !index_cycle <> stop_at_cycle do
         Int.incr index_cycle;
         match
           if no_input
           then Some ""
           else (
             if is_multi_threaded
             then
               ignore
                 (Core_unix.select
                    ~restart:true
                    ~read:[ Core_unix.stdin ]
                    ~write:[]
                    ~except:[]
                    ~timeout:`Never
                    ()
                  : Core_unix.Select_fds.t);
             In_channel.input_line In_channel.stdin)
         with
         | None -> return (Ok ())
         | Some line ->
           (match run_line line with
            | Error _ as error -> return error
            | Ok () -> ())
       done;
       Ok ())
     |> function
     | Ok () -> ()
     | Error error ->
       prerr_endline (Error.to_string_hum error);
       Stdlib.exit 1)
;;

let run ?readme t_param =
  Commandlang_to_cmdliner.run
    (main ?readme t_param)
    ~name:"bopkit.block"
    ~version:"%%VERSION%%"
;;
