open! Core

(** Expanded netlist is an intermediate representation built during the analysis
    of a circuit. Constructs such as control structures and imbrications have
    been developed. This representation is used by different parts of bopkit
    such as the simulator, bop2c, etc. *)

type memory =
  { loc : Loc.t
  ; name : string
  ; memory_kind : Netlist.memory_kind
  ; address_width : int
  ; data_width : int
  ; memory_content : Bit_matrix.t option
  }

type external_method =
  { method_name : string
  ; attributes : string list
  }

type external_block =
  { loc : Loc.t
  ; name : string
  ; attributes : string list
  ; init_messages : string list
  ; methods : external_method list
  ; command : string
  }

(** Once the control structures have been developed, all the indexes are
    computed and are integers. *)

type index =
  | Interval of int * int
  | Index of int
[@@deriving equal, sexp_of]

type variable =
  | Signal of { name : string }
  | Bus of
      { loc : Loc.t
      ; name : string
      ; indexes : index list
      }
  | Internal of int

type variables =
  { expanded : string list
  ; original_grouping : variable list
  }

type call =
  | Block of { name : string }
  | External_block of
      { name : string
      ; method_name : string option
      ; external_arguments : string list
      }

(** Flat nodes where the nested inputs have all been developed. *)
type node =
  { loc : Loc.t
  ; call : call
  ; inputs : variables
  ; outputs : variables
  }

(** Blocks with parameters are produced on demand, with a fresh name for each
    variation of required parameters. At the moment, the actual name is made of
    a concatenation of the original name plus additional characters taken from
    the concrete syntax, such as '[', ']', etc to make it unique. Example:
    "name[4]". *)
type block =
  { loc : Loc.t
  ; name : string
  ; attributes : string list
  ; inputs : variables
  ; outputs : variables
  ; unused_variables : variables
  ; nodes : node list
  }

type t =
  { filenames : string list
  ; rom_memories : Bit_matrix.t array
  ; memories : memory array
  ; external_blocks : external_block list
  ; blocks : block list
  ; main_block_name : string
  }
