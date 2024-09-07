%{
  open Bopkit_process

  let operator_name (argument : Program.Argument.t) =
    match argument with
    | Constant { value = _ } -> failwith "An operator is expected, not a constant"
    | Ident { ident } ->
      Loc.Txt.map ident ~f:(fun ident ->
        ident |> Ident.to_string |> Operator_name.of_string)
  ;;
%}

%token EOF
%token INPUT
%token OUTPUT
%token ASSIGN
%token <int> INT
%token <Bopkit_process.Ident.t> IDENT
%token COMMA
%token <string option> NL

%type <Bopkit_process.Program.t> program

%start program

%%

program:
  | c1=NL* input=input c2=NL assignments=assignment* output=output c4=NL* EOF
    { { Program.
        input
      ; output
      ; assignments
      ; head_comments = List.filter_opt (c1 @ [ c2 ])
      ; tail_comments = List.filter_opt c4
      }
    }
;

input:
  | INPUT inputs=ident_list { Array.of_list inputs }
;

output:
  | OUTPUT outputs=ident_list { Array.of_list outputs }
;

argument:
  | ident=ident  { Program.Argument.Ident { ident } }
  | value=INT    { Program.Argument.Constant { value } }
;

assignment:
  | c1=NL* result=ident ASSIGN op=argument arg=argument c2=NL
    { Program.Assignment.
      { comments = List.filter_opt (c1 @ [c2])
      ; result
      ; operator_name = operator_name op
      ; arguments = [| arg |]
      }
    }
  | c1=NL* result=ident ASSIGN arg1=argument op=argument arg2=argument c2=NL
    { Program.Assignment.
      { comments = List.filter_opt (c1 @ [c2])
      ; result
      ; operator_name = operator_name op
      ; arguments = [| arg1 ; arg2 |]
      }
    }
;

ident_list :
  | ident_list=separated_list(COMMA, ident) { ident_list }
;

ident :
  | ident=IDENT { Loc.Txt.create $loc ident }
;

