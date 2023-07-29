open! Core
open! Pp.O

let input_name = "input_string"
let output_name = "output_string"

let output_declaration ~output_width:n =
  Pp.verbatim (sprintf "char %s[%d] = %S;" output_name (succ n) (String.make n '0'))
;;

let input_declaration ~input_width:i =
  Pp.verbatim (sprintf "unsigned char %s[%d];" input_name (succ i))
;;

let of_id s a = Pp.verbatim (sprintf "%s = %s;" s a)
let of_not s a = Pp.verbatim (sprintf "%s = !%s;" s a)
let of_and s a b = Pp.verbatim (sprintf "%s = %s && %s;" s a b)
let of_or s a b = Pp.verbatim (sprintf "%s= %s || %s;" s a b)
let of_xor s a b = Pp.verbatim (sprintf "%s = %s ? !%s : %s;" s a b b)
let of_mux s e a b = Pp.verbatim (sprintf "%s = %s ? %s : %s;" s e a b)

let input ~input_width:n =
  let parameters =
    [ Pp.verbatim "("
    ; Pp.concat
        ~sep:(Pp.verbatim "," ++ Pp.space)
        (List.init n ~f:(fun i -> Pp.verbatim (sprintf "unsigned char *e%d" i)))
    ; Pp.verbatim ")"
    ]
    |> Pp.concat
    |> Pp.box ~indent:1
  in
  let body =
    Pp.concat
      ~sep:Pp.newline
      (List.init n ~f:(fun i ->
         Pp.verbatim (sprintf "*e%d = (%s[%d] == '1');" i input_name i)))
  in
  [ [ Pp.verbatim "void input" ++ parameters ++ Pp.verbatim " {"
    ; Pp.newline
    ; Pp.verbatim (sprintf "readLineFromStdin(%s, %d);" input_name (succ n))
    ; (if n > 0 then Pp.newline else Pp.nop)
    ; body
    ]
    |> Pp.concat
    |> Pp.box ~indent:2
  ; Pp.verbatim "}"
  ]
  |> Pp.concat ~sep:Pp.newline
;;

let output ~output_width:n =
  let parameters =
    [ Pp.verbatim "("
    ; Pp.concat
        ~sep:(Pp.verbatim "," ++ Pp.space)
        (List.init n ~f:(fun i -> Pp.verbatim (sprintf "unsigned char e%d" i)))
    ; Pp.verbatim ")"
    ]
    |> Pp.concat
    |> Pp.box ~indent:1
  in
  let body =
    Pp.concat
      ~sep:Pp.newline
      (List.init n ~f:(fun i ->
         Pp.verbatim (sprintf "%s[%d] = e%d ? '1' : '0';" output_name i i)))
  in
  [ [ Pp.verbatim "void output" ++ parameters ++ Pp.verbatim " {"
    ; Pp.newline
    ; body
    ; (if n > 0 then Pp.newline else Pp.nop)
    ; Pp.verbatim (sprintf "fprintf(stdout, \"%%s\\n\", %s);" output_name)
    ; Pp.newline
    ; Pp.verbatim "fflush(stdout);"
    ]
    |> Pp.concat
    |> Pp.box ~indent:2
  ; Pp.verbatim "}"
  ]
  |> Pp.concat ~sep:Pp.newline
;;

let call ~name ~args =
  [ Pp.verbatim name
  ; Pp.verbatim "("
  ; [ Pp.concat_map
        (args |> Array.to_list)
        ~sep:(Pp.verbatim "," ++ Pp.space)
        ~f:(fun arg -> Pp.verbatim arg)
    ; Pp.verbatim ")"
    ]
    |> Pp.concat
    |> Pp.box ~indent:0
  ]
  |> Pp.concat
;;

let init_tab1 t =
  Pp.concat
    [ Pp.verbatim "{"
    ; Pp.concat_map
        (t |> Array.to_list)
        ~sep:(Pp.verbatim "," ++ Pp.space)
        ~f:(fun b -> Pp.verbatim (if b then "1" else "0"))
    ; Pp.verbatim "}"
    ]
  |> Pp.box ~indent:2
;;

let init_tab2 t =
  Pp.concat
    [ Pp.verbatim "{"
    ; Pp.newline
    ; Pp.concat_map (t |> Array.to_list) ~sep:(Pp.verbatim "," ++ Pp.space) ~f:init_tab1
    ; Pp.verbatim "}"
    ]
;;

let index_of_bits index t =
  let len = Array.length t in
  if len = 0
  then Pp.verbatim (sprintf "%s = 0;" index)
  else (
    let rec aux acc power i =
      if i >= len
      then acc ++ Pp.verbatim ";"
      else (
        let multiplier = t.(i) in
        let acc =
          acc
          ++
          if String.equal multiplier "0"
          then Pp.nop
          else Pp.verbatim (sprintf " + %d * %s" power multiplier)
        in
        aux acc (2 * power) (succ i))
    in
    aux (Pp.verbatim (sprintf "%s = %s" index t.(0))) 2 1 |> Pp.box ~indent:2)
;;

let assign_bits_of_array ~prefix ~array ~len =
  List.init len ~f:(fun i -> Pp.verbatim (sprintf "%s%d = %s[%d];" prefix i array i))
  |> Pp.concat ~sep:Pp.newline
;;

let assign_array_of_bits ~array ~prefix ~len =
  List.init len ~f:(fun i -> Pp.verbatim (sprintf "%s[%d] = %s%d;" array i prefix i))
  |> Pp.concat ~sep:Pp.newline
;;

let function_ram ~id ~num_addresses ~data_width =
  let bits = int_of_float (log (float_of_int num_addresses) /. log 2.) in
  let entrees = (2 * bits) + 1 + data_width in
  let tab_read_add = Array.init bits ~f:(fun i -> Printf.sprintf "r%d" i) in
  let tab_write_add = Array.init bits ~f:(fun i -> Printf.sprintf "e%d" i) in
  let tab_data = Array.init data_width ~f:(fun i -> Printf.sprintf "d%d" i) in
  let tab_sorties = Array.init data_width ~f:(fun i -> Printf.sprintf "s%d" i) in
  let pp =
    let args =
      Array.concat [ tab_read_add; tab_write_add; [| "en" |]; tab_data; tab_sorties ]
      |> Array.mapi ~f:(fun i arg ->
        (if i < entrees then "unsigned char " else "unsigned char *") ^ arg)
    in
    call ~name:(Printf.sprintf "void call_ram%d" id) ~args
  in
  [ [ pp ++ Pp.verbatim " {"
    ; Pp.verbatim "int index;"
    ; [ Pp.verbatim "if (en) {"
      ; index_of_bits "index" tab_write_add
      ; assign_array_of_bits
          ~array:(sprintf "ram%d[index]" id)
          ~prefix:"d"
          ~len:data_width
      ]
      |> Pp.concat ~sep:Pp.newline
      |> Pp.box ~indent:2
    ; [ Pp.verbatim "} else {"
      ; index_of_bits "index" tab_read_add
      ; assign_bits_of_array
          ~prefix:"*s"
          ~array:(sprintf "ram%d[index]" id)
          ~len:data_width
      ]
      |> Pp.concat ~sep:Pp.newline
      |> Pp.box ~indent:2
    ; Pp.verbatim "}"
    ]
    |> Pp.concat ~sep:Pp.newline
    |> Pp.box ~indent:2
  ; Pp.verbatim "}"
  ]
  |> Pp.concat ~sep:Pp.newline
;;

let function_rom ~id ~num_addresses ~data_width =
  let bits = int_of_float (log (float_of_int num_addresses) /. log 2.) in
  let tab_entrees = Array.init bits ~f:(fun i -> Printf.sprintf "e%d" i) in
  let tab_sorties = Array.init data_width ~f:(fun i -> Printf.sprintf "s%d" i) in
  let pp =
    let args =
      Array.concat [ tab_entrees; tab_sorties ]
      |> Array.mapi ~f:(fun i arg ->
        (if i < bits then "unsigned char " else "unsigned char *") ^ arg)
    in
    call ~name:(sprintf "void call_rom%d" id) ~args
  in
  [ [ pp ++ Pp.verbatim " {"
    ; Pp.verbatim "int " ++ index_of_bits "index" tab_entrees
    ; assign_bits_of_array ~prefix:"*s" ~array:(sprintf "rom%d[index]" id) ~len:data_width
    ]
    |> Pp.concat ~sep:Pp.newline
    |> Pp.box ~indent:2
  ; Pp.verbatim "}"
  ]
  |> Pp.concat ~sep:Pp.newline
;;

let of_ram ~id ~contents =
  let num_addresses = Array.length contents in
  let data_width = Array.length contents.(0) in
  let decl =
    Pp.concat
      [ Pp.verbatim (sprintf "unsigned char ram%d[%d][%d] = " id num_addresses data_width)
      ; init_tab2 contents
      ; Pp.verbatim ";"
      ; Pp.newline
      ]
    |> Pp.box ~indent:2
  in
  Pp.concat ~sep:Pp.newline [ decl; function_ram ~id ~num_addresses ~data_width ]
;;

let of_rom ~id ~contents =
  let num_addresses = Array.length contents in
  let data_width = Array.length contents.(0) in
  let decl =
    Pp.concat
      [ Pp.verbatim (sprintf "unsigned char rom%d[%d][%d] = " id num_addresses data_width)
      ; init_tab2 contents
      ; Pp.verbatim ";"
      ; Pp.newline
      ]
    |> Pp.box ~indent:2
  in
  Pp.concat ~sep:Pp.newline [ decl; function_rom ~id ~num_addresses ~data_width ]
;;

let read_line_from_stdin =
  lazy
    ({|
/* Reads a line of text from standard input into a buffer of given size.
   Returns 0 on success, and exit 1 on error. */
int readLineFromStdin(char* buffer, size_t bufferSize) {
  /* Read a line of text from standard input into the buffer. */
  size_t i = 0;
  int c = getchar();
  while (i < bufferSize-1 && c != '\n' && c != EOF) {
    buffer[i] = (char)c;
    i++;
    c = getchar();
  }
  buffer[i] = '\0';

  if (i == 0 && c == EOF) {
    exit(0);
  }

  if (i < bufferSize-1) {
    fprintf(stderr, "Input line too short.\n");
    fprintf(stderr, "Expected %zu bits - got %zu.\n", bufferSize-1, i);
    fflush(stderr);
    exit(1);
  }

  /* Check that the line ends with a newline character */
  if (i == bufferSize-1 && c != '\n' && c != EOF) {
    fprintf(stderr, "Input line too long.\n");
    fprintf(stderr, "Expected %zu bits followed by '\\n'.\n", bufferSize-1);
    exit(1);
  }

  return 0;
}
|}
     |> String.strip
     |> Pp.verbatim)
;;
