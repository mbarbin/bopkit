open! Core

(** The declaration of the variable that will hold the input of the circuit. *)
val input_declaration : input_width:int -> _ Pp.t

(** The function that assigned an input line to the circuit's input variables.
    To be called once per cycle. *)
val input : input_width:int -> _ Pp.t

(** The declaration of the variable that will hold the output of the circuit. *)
val output_declaration : output_width:int -> _ Pp.t

(** The function that prints the output to stdout, to be called once per cycle. *)
val output : output_width:int -> _ Pp.t

(** The code of the function that reads the input from stdin. *)
val read_line_from_stdin : _ Pp.t Lazy.t

(** The application of a function to its arguments. *)
val call : name:string -> args:string array -> _ Pp.t

(** {1 Primitives} *)

val of_id : string -> string -> _ Pp.t
val of_not : string -> string -> _ Pp.t
val of_and : string -> string -> string -> _ Pp.t
val of_or : string -> string -> string -> _ Pp.t
val of_xor : string -> string -> string -> _ Pp.t
val of_mux : string -> string -> string -> string -> _ Pp.t

(** {1 Memories} *)

val of_ram : id:int -> contents:Bit_matrix.t -> _ Pp.t
val of_rom : id:int -> contents:Bit_matrix.t -> _ Pp.t
