%{
%}

%token EOF
%token <string> IDENT
%token <string> STRING
%token <string> BITS

%type <Protocol.t> protocol

%start protocol

%%

protocol :
 | method_name=IDENT? arguments=list(STRING) bits=BITS? EOF
     {
       let method_kind : Protocol.Method_kind.t =
         match method_name with
         | None -> Main
         | Some method_name -> Named { method_name; arguments }
       in
       { Protocol.method_kind; bits = Option.value bits ~default:"" }
     }
;
