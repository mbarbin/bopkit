open! Core

type t = Stdune.Loc.t =
  { start : Source_code_position.t
  ; stop : Source_code_position.t
  }
[@@deriving equal, sexp_of]

let equal_ignores_positions = ref false
let equal t1 t2 = !equal_ignores_positions || equal t1 t2
let include_sexp_of_positions = ref false
let sexp_of_t t = if !include_sexp_of_positions then sexp_of_t t else Atom "_"
let create (start, stop) = { start; stop }
let of_pos p = { start = p; stop = p }

let to_string t =
  Printf.sprintf
    "File %S, line %d, characters %d-%d:"
    t.start.pos_fname
    t.start.pos_lnum
    (t.start.pos_cnum - t.start.pos_bol)
    (t.stop.pos_cnum - t.stop.pos_bol)
;;

let to_file_colon_line t = Stdune.Loc.to_file_colon_line t
let dummy_pos = { start = Lexing.dummy_pos; stop = Lexing.dummy_pos }

let in_file_at_line ~filename ~line =
  let p = { Lexing.pos_fname = filename; pos_lnum = line; pos_cnum = 0; pos_bol = 0 } in
  { start = p; stop = p }
;;

let in_file ~filename = in_file_at_line ~filename ~line:1

let with_dummy_pos t =
  { start = { Lexing.dummy_pos with pos_fname = t.start.pos_fname }
  ; stop = { Lexing.dummy_pos with pos_fname = t.stop.pos_fname }
  }
;;

let filename t = t.start.pos_fname
let line t = t.start.pos_lnum
