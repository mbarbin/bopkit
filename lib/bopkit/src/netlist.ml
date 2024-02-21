type include_file =
  { loc : Loc.t
  ; comments : Comments.t
  ; include_file_kind : include_file_kind
  }
[@@deriving equal, sexp_of]

and include_file_kind =
  | File_path of Fpath.t
  | Distribution of
      { file : Fpath.t
      ; file_is_quoted : bool
      }
[@@deriving equal, sexp_of]

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

type memory_kind =
  | ROM
  | RAM
[@@deriving equal, sexp_of]

type memory_content =
  | Text of string
  | File of Fpath.t
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

type functional_argument =
  { name : string
  ; name_is_quoted : bool
  }
[@@deriving equal, sexp_of]

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

type external_call_output_size =
  | Inferred
  | Specified of Arithmetic_expression.t
[@@deriving equal, sexp_of]

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

module Interface = struct
  type t =
    | Standard of { name : string }
    | Parametrized of
        { name : string
        ; parameters : string list
        ; functional_parameters : string list
        }
  [@@deriving equal, sexp_of]
end

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
