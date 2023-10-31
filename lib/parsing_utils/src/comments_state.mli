(** This module allows attaching comments to tokens, thanks to a collaboration
    between a parser and a lexer.

    The attachment of comments supported here is opinionated, and specific. In
    particular, it can't attach comments to a token that appears prior to these
    comments within the lexems sequence.

    We hope that this API will allow attaching comments to AST nodes with
    minimal changes to an existing lexer/parser pair. Yet the comments will be
    part of the returned parsed AST, which is nice for the implementation of
    pretty-printers. *)

(** As it currently stands, the module is not thread safe, and uses some global
    state. It is important to [reset] the state between each invocation of a
    lexer/parser pair, otherwise the behavior is not specified and may cause
    comments to leak between unrelated parsers. [reset] is done for you if your
    invocation is done through {!wrap} or the [Parsing_utils.parse*] functions
    (for example {!Parsing_utils.parse_file}). If you are using your parser and
    lexer directly, you should handle the reset. *)
val reset : unit -> unit

(** To be called once the parsing is done, to attach all comments to comment
    nodes. Like {!reset}, this is handled for you if you use {!wrap}, or
    [Parsing_util].

    [attach_comments] causes all functions [f] supplied to {!val:comment_node} to be
    executed. *)
val attach_comments : unit -> unit

(** Wrap the execution of a function with proper calls to {!reset} and
    {!attach_comments}. The execution of [f] is protected so that
    {!attach_comments} is still called even if [f] raises. *)
val wrap : f:(unit -> 'a) -> 'a

(** {1 Lexer functions} *)

(** To be called by the lexer each time it encounters a comment. Comments will
    be attached to the next comment_node inserted by the parser. *)
val add_comment : lexbuf:Lexing.lexbuf -> comment:string -> unit

(** {1 Parser functions} *)

type 'a comment_node

(** [comment_node ~attached_to:p ~f] is used by the parser to create a
    comment_node that will be used to retrieve all comments attached to that
    position. For example:

    {[
      my_rule:
        | _tok=TOK1 rule=rule1 TOK2
          { { rule = rule1
            ; comments =
                Comments_state.retrieve_comments
                  ~attached_to:($startpos(_tok))
                  ~f:Fn.id
            }
          }
      ;
    ]}

    An empty node is created and returned immediately during the construction of
    the parsed tree. However, the node won't contain any comments until the very
    end, when {!attach_comments} will be executed. *)
val comment_node : attached_to:Lexing.position -> f:(string list -> 'a) -> 'a comment_node

(** {1 Debugging} *)

(** You may turn it on temporarily and inspect messages sent to stderr. *)
val debug : bool ref

(** {1 Part for AST} *)

module Comment_node : sig
  type 'a t = 'a comment_node [@@deriving equal, sexp_of]

  val return : 'a -> 'a t

  (** Once {!attach_comments} has been called, all comments are attached to
      nodes, and all functions [f] supplied to {!val:comment_node} are executed. If
      {!attach_comments} hasn't been called, this function will always raise. *)
  val value_exn : 'a t -> 'a
end
