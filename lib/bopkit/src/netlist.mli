(** This file defines the abstract syntax tree of [*.bop] files. For each file,
    the parser returns a single value of type [t]. *)

(** Including other files (with #include). *)
type include_file =
  { loc : Loc.t
  ; comments : Comments.t
  ; include_file_kind : include_file_kind
  }
[@@deriving equal, sexp_of]

(** This encodes the difference between including a file from the standard
    library, and a file from a user's project.

    {v
     #include <stdlib.bop>
     #include "my_file.bop"
    v} *)
and include_file_kind =
  | File_path of string
  | Distribution of
      { file : string
      ; file_is_quoted : bool
      }
[@@deriving equal, sexp_of]

(** Defining parameters (with #define). *)
type parameter =
  { loc : Loc.t
  ; comments : Comments.t
  ; name : string
  ; parameter_value : parameter_value
  }
[@@deriving equal, sexp_of]

and parameter_value =
  | DefCondInt of
      (Conditional_expression.t * Arithmetic_expression.t * Arithmetic_expression.t)
  | DefInt of Arithmetic_expression.t
  | DefCondString of (Conditional_expression.t * string * string)
  | DefString of string
[@@deriving equal, sexp_of]

(** The 2 different kinds of memory. ROM is read-only, and RAM allows read/write. *)
type memory_kind =
  | ROM
  | RAM
[@@deriving equal, sexp_of]

(** The different ways to specify the initial contents of memories. *)
type memory_content =
  | Text of string
  | File of string
  | Zero
[@@deriving equal, sexp_of]

type memory =
  { loc : Loc.t
  ; comments : Comments.t
  ; name : string
  ; memory_kind : memory_kind
  ; address_width : Arithmetic_expression.t
  ; data_width : Arithmetic_expression.t
  ; memory_content : memory_content
  }
[@@deriving equal, sexp_of]

type external_block_api_element =
  | Init_message of
      { loc : Loc.t
      ; comments : Comments.t
      ; message : string
      }
  | Method of
      { loc : Loc.t
      ; comments : Comments.t
      ; method_name : string
      ; method_name_is_quoted : bool
      ; attributes : string list
      }
[@@deriving equal, sexp_of]

and external_block =
  { loc : Loc.t
  ; head_comments : Comments.t
  ; tail_comments : Comments.t
  ; name : string
  ; attributes : string list
  ; api : external_block_api_element Control_structure.t list
  ; command : string
  }
[@@deriving equal, sexp_of]

(** Functional argument may be added to parameterized functions. When calling a
    function with functional parameters in its formal definition, there's the
    question of whether the argument is a string with vars such as
    [<"name_%{var}">] or whether the call is merely an identifier, such as
    [<ident>]. The second field distinguishes the two. *)
type functional_argument =
  { name : string
  ; name_is_quoted : bool
  }
[@@deriving equal, sexp_of]

(** Variables may be followed by indexes, to expand signals into buses, or
    collections of buses. Here are example of indexes, along with their
    expanded version.

    {v
      a[0]     --->  a[0]
      a[0..3]  --->  a[0], a[1], a[2], a[3]
      a:[4]    --->  a[0], a[1], a[2], a[3]
      a:[-4]   --->  a[3], a[2], a[1], a[0]
    v}

    When multiple indexes are used in sequence, the development goes from right
    to left, that is:

    {v
      a:[2]:[3] --->  a[0][0], a[0][1], a[0][2], a[1][0], a[1][1], a[1][2]
    v} *)
type index =
  | Segment of Arithmetic_expression.t
  | Interval of Arithmetic_expression.t * Arithmetic_expression.t
  | Index of Arithmetic_expression.t
[@@deriving equal, sexp_of]

type variable =
  | Signal of { name : string }
  | Bus of
      { loc : Loc.t
      ; name : string
      ; indexes : index list
      }
[@@deriving equal, sexp_of]

(** In the case of a call to an external block, the output size may not always
    be known. Sometimes it can be inferred, or computed from an expression. *)
type external_call_output_size =
  | Inferred
  | Specified of Arithmetic_expression.t
[@@deriving equal, sexp_of]

(** The different kinds of calls to another block. The block that is called can
    be a block previously defined, and an external block, or a external construct.
    The syntax is different for all three:

    {v
      output = block(input);
      output = $block.method(input);
      output = external("./command.exe", input);
    v} *)
type call =
  | Block of
      { name : string
      ; arguments : Arithmetic_expression.t list
      ; functional_arguments : functional_argument list
      }
  | External_block of
      { name : string
      ; method_name : string option
      ; method_name_is_quoted : bool
      ; external_arguments : string list
      ; output_size : external_call_output_size
      }
  | External_command of
      { command : string
      ; output_size : external_call_output_size
      }
[@@deriving equal, sexp_of]

(** Node's input may be variables or the outputs of calls to nested nodes.

    Here is an example of a node with nested inputs:

    {v
      e = or(and(a, b), xor(c, d));
    v} *)
type nested_inputs =
  | Variables of
      { loc : Loc.t
      ; comments : Comments.t
      ; variables : variable list
      }
  | Nested_node of
      { loc : Loc.t
      ; comments : Comments.t
      ; call : call
      ; inputs : nested_inputs list
      }
[@@deriving equal, sexp_of]

type node =
  { loc : Loc.t
  ; comments : Comments.t
  ; call : call
  ; inputs : nested_inputs list
  ; outputs : variable list
  }
[@@deriving equal, sexp_of]

module Interface : sig
  type t =
    | Standard of { name : string }
    | Parametrized of
        { name : string
        ; parameters : string list
        ; functional_parameters : string list
        }
  [@@deriving equal, sexp_of]
end

(** The definition of a new block. *)
type block =
  { loc : Loc.t
  ; head_comments : Comments.t
  ; tail_comments : Comments.t
  ; name : Interface.t
  ; attributes : string list
  ; inputs : variable list
  ; outputs : variable list
  ; unused_variables : variable list
  ; nodes : node Control_structure.t list
  }
[@@deriving equal, sexp_of]

type t =
  { include_files : include_file list
  ; parameters : parameter list
  ; memories : memory list
  ; external_blocks : external_block list
  ; blocks : block list
  ; eof_comments : Comments.t
  }
[@@deriving equal, sexp_of]
