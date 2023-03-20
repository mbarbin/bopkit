%{
  open! Core
  open! Bopkit.Netlist
%}

%type <Bopkit.Netlist.include_file> include_file

%%

%public include_file:
  | _tag=TAG_INCLUDE STRING
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; include_file_kind = File_path $2
      }
    }

  | _tag=TAG_INCLUDE SPPETIT IDENT SPGRAND
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; include_file_kind = Distribution { file = $3; file_is_quoted = false }
      }
    }

  | _tag=TAG_INCLUDE SPPETIT path=STRING SPGRAND
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; include_file_kind = Distribution { file = path; file_is_quoted = true }
      }
    }

  | _tag=TAG_INCLUDE SPPETIT IDENT POINT IDENT SPGRAND
    { { loc = Loc.create $loc
      ; comments = Comments.make ~attached_to:($startpos(_tag))
      ; include_file_kind = Distribution { file = $3^"."^$5; file_is_quoted = false }
      }
    }
;
