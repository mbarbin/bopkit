%{
  open! Core
%}

%token EOF
%token COMMA
%token COLON
%token DEFINE
%token END
%token MACRO
%token NEWLINE
%token <string> COMMENT
%token <string> IDENT
%token <string> LABEL_ARGUMENT
%token <string> PARAMETER_ARGUMENT
%token <Visa.Instruction_name.t> INSTRUCTION_NAME
%token <string> INT
%token <int> INT_ARGUMENT
%token <Visa.Register_name.t> REGISTER_NAME

%type <Visa.Program.t> program

%start program

%%

program :
 | EOF { [] }
 | hd=top_level_construct tl=program { hd :: tl }
;

top_level_construct :
 | NEWLINE
   { Visa.Program.Top_level_construct.Newline }
 | text=COMMENT NEWLINE
   { Visa.Program.Top_level_construct.Comment { text } }
 | DEFINE constant_name=constant_name value=INT NEWLINE
   { Visa.Program.Top_level_construct.Constant_definition
     { constant_name
     ; constant_kind = Address { address = (Visa.Address.of_int (int_of_string value)) }
     }
   }
 | DEFINE constant_name=constant_name value=INT_ARGUMENT NEWLINE
   { Visa.Program.Top_level_construct.Constant_definition
     { constant_name
     ; constant_kind = Value { value }
     }
   }
 | MACRO macro_name=macro_name parameters=macro_parameters NEWLINE body=assembly_instructions END NEWLINE
   { Visa.Program.Top_level_construct.Macro_definition
     { macro_name
     ; parameters
     ; body
     }
   }
 | label=IDENT COLON
 | label=INT COLON
   { Visa.Program.Top_level_construct.Label_introduction
     { label =
        With_loc.create $loc
         (Visa.Label.of_string label)
     }
   }
 | assembly_instruction=assembly_instruction
   { Visa.Program.Top_level_construct.Assembly_instruction { assembly_instruction }
   }
;

macro_name:
 | macro_name=IDENT
   { With_loc.create $loc
      (Visa.Macro_name.of_string macro_name)
   }
;

constant_name:
 | constant_name=IDENT
   { With_loc.create $loc
      (Visa.Constant_name.of_string constant_name)
   }
;

macro_parameters :
 | ident_list=separated_list(COMMA, IDENT)
   { List.map ident_list ~f:Visa.Parameter_name.of_string }
;

assembly_instructions :
 | { [] }
 | hd=assembly_instruction tl=assembly_instructions { hd :: tl }
;

assembly_instruction :
 | operation_kind=operation_kind arguments=arguments NEWLINE
   { { Visa.Assembly_instruction.
        loc = Loc.create $loc(operation_kind)
      ; operation_kind
      ; arguments
      }
    }
;

operation_kind :
 | macro_name=IDENT
   { Visa.Assembly_instruction.Operation_kind.Macro_call
     { macro_name = Visa.Macro_name.of_string macro_name }
   }
 | instruction_name=INSTRUCTION_NAME
   { Visa.Assembly_instruction.Operation_kind.Instruction
     { instruction_name }
   }
;

arguments :
 | arguments=separated_list(COMMA, argument) { arguments }
;

argument:
 | argument_kind=argument_kind { With_loc.create $loc argument_kind }
;

argument_kind :
 | constant_name=IDENT
   { Visa.Assembly_instruction.Argument.Constant
     { constant_name = Visa.Constant_name.of_string constant_name }
   }
 | value=INT
   { Visa.Assembly_instruction.Argument.Address
     { address = Visa.Address.of_int (int_of_string value) }
   }
 | value=INT_ARGUMENT
   { Visa.Assembly_instruction.Argument.Value { value }
   }
 | label=LABEL_ARGUMENT
   { Visa.Assembly_instruction.Argument.Label
     { label = Visa.Label.of_string label }
   }
 | parameter=PARAMETER_ARGUMENT
   { Visa.Assembly_instruction.Argument.Parameter
     { parameter_name = Visa.Parameter_name.of_string parameter }
   }
 | register_name=REGISTER_NAME
   { Visa.Assembly_instruction.Argument.Register { register_name } }
;
