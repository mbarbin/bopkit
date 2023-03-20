open! Core

(** Pretty-printing comments that are found in bopkit files.

    The lexer/parser attaches the raw text to AST nodes, containing the entire
    comment lexem, which includes the comments prefix and suffixes, for example:

    {["// this was a single line comment"]}

    Or:

    {["/**\nThis was a multi-line\ndocumentation comment\n*/"]}

    This module implements the rendering of the comment back into a pretty
    printed form, to be used by the fmt code. *)

type t [@@deriving equal, sexp_of]

(** Parses a comment to figure out which kind it is. If the comment comes from
    the parser, you may assume that this function will return [Some _] (it is
    an internal error otherwise). *)
val parse : string -> t option

(** Produce an internal error log that contains the comment, for a bug report. *)
val parse_exn : string -> t

(** Produces the list of strings to be passed to a pretty-printer, to be
    separated by [Pp.newline] so as to respect the potential enclosing box
    indentation. *)
val render : t -> string list
