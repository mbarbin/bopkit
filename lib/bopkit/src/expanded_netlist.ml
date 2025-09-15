(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

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

type node =
  { loc : Loc.t
  ; call : call
  ; inputs : variables
  ; outputs : variables
  }

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
  { paths : Fpath.t list
  ; rom_memories : Bit_matrix.t array
  ; memories : memory array
  ; external_blocks : external_block list
  ; blocks : block list
  ; main_block_name : string
  }
