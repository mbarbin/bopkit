open! Or_error.Let_syntax

(* $MDX part-begin=program *)
let loop () : Visa.Program.t =
  Visa_dsl.program (fun t ->
    let open Visa_dsl.O in
    let loop = add_new_label t "LOOP" in
    load_value t (value 1) R0;
    add t;
    write t R1 (output 0);
    jmp t loop)
;;

(* $MDX part-end *)

(* $MDX part-begin=loop-pp *)
let%expect_test "loop pp" =
  let program = loop () in
  print_endline (Pp_extended.to_string (Visa_pp.Program.pp program));
  [%expect {|
    LOOP:
      load #1, R0
      add
      write R1, 0
      jmp @LOOP |}]
;;

(* $MDX part-end *)

(* $MDX part-begin=loop-run *)
let%expect_test "loop run" =
  let program = loop () in
  let config = Visa_simulator.Config.create ~sleep:false ~stop_after_n_outputs:20 () in
  Error_log.For_test.report (fun error_log ->
    let%bind visa_simulator = Visa_simulator.create ~config ~error_log ~program in
    Visa_simulator.run visa_simulator ~error_log);
  [%expect
    {|
    1000000000000000000000000000000000000000000000000000000000000000
    0100000000000000000000000000000000000000000000000000000000000000
    1100000000000000000000000000000000000000000000000000000000000000
    0010000000000000000000000000000000000000000000000000000000000000
    1010000000000000000000000000000000000000000000000000000000000000
    0110000000000000000000000000000000000000000000000000000000000000
    1110000000000000000000000000000000000000000000000000000000000000
    0001000000000000000000000000000000000000000000000000000000000000
    1001000000000000000000000000000000000000000000000000000000000000
    0101000000000000000000000000000000000000000000000000000000000000
    1101000000000000000000000000000000000000000000000000000000000000
    0011000000000000000000000000000000000000000000000000000000000000
    1011000000000000000000000000000000000000000000000000000000000000
    0111000000000000000000000000000000000000000000000000000000000000
    1111000000000000000000000000000000000000000000000000000000000000
    0000100000000000000000000000000000000000000000000000000000000000
    1000100000000000000000000000000000000000000000000000000000000000
    0100100000000000000000000000000000000000000000000000000000000000
    1100100000000000000000000000000000000000000000000000000000000000
    0010100000000000000000000000000000000000000000000000000000000000 |}];
  ()
;;

(* $MDX part-end *)

let%expect_test "minus" =
  let open Visa_dsl.O in
  let macro_minus t a b =
    load_value t b R0;
    not_ t R0;
    load_value t (value 1) R1;
    add t;
    swc t;
    load_value t a R1;
    add t
  in
  let ocaml_macro =
    Visa_dsl.program (fun t ->
      macro_minus t (value 15) (value 7);
      write t R1 (output 0);
      macro_minus t (value 185) (value 57);
      write t R1 (output 1))
  in
  let visa_macro =
    let minus =
      macro
        ~name:"minus"
        ~parameters:(T2 (Value "a", Value "b"))
        ~f:(fun t (a, b) -> macro_minus t a b)
    in
    Visa_dsl.program (fun t ->
      define_macro t minus;
      call_macro t minus (value 15, value 7);
      write t R1 (output 0);
      call_macro t minus (value 185, value 57);
      write t R1 (output 1))
  in
  print_endline (Pp_extended.to_string (Visa_pp.Program.pp ocaml_macro));
  [%expect
    {|
    load #7, R0
    not R0
    load #1, R1
    add
    swc
    load #15, R1
    add
    write R1, 0
    load #57, R0
    not R0
    load #1, R1
    add
    swc
    load #185, R1
    add
    write R1, 1 |}];
  print_endline (Pp_extended.to_string (Visa_pp.Program.pp visa_macro));
  [%expect
    {|
    macro minus a, b
      load $b, R0
      not R0
      load #1, R1
      add
      swc
      load $a, R1
      add
    end
    minus #15, #7
    write R1, 0
    minus #185, #57
    write R1, 1 |}];
  let run program =
    let config = Visa_simulator.Config.create ~sleep:false ~stop_after_n_outputs:2 () in
    Error_log.For_test.report (fun error_log ->
      let%bind visa_simulator = Visa_simulator.create ~config ~error_log ~program in
      Visa_simulator.run visa_simulator ~error_log)
  in
  run ocaml_macro;
  [%expect
    {|
    0001000000000000000000000000000000000000000000000000000000000000
    0001000000000001000000000000000000000000000000000000000000000000 |}];
  run visa_macro;
  [%expect
    {|
    0001000000000000000000000000000000000000000000000000000000000000
    0001000000000001000000000000000000000000000000000000000000000000 |}];
  Error_log.For_test.report (fun error_log ->
    let%bind executable_with_ocaml_macro =
      Visa_assembler.program_to_executable ~program:ocaml_macro ~error_log
    in
    let%bind executable_with_visa_macro =
      Visa_assembler.program_to_executable ~program:visa_macro ~error_log
    in
    if Visa.Executable.equal executable_with_ocaml_macro executable_with_visa_macro
    then return ()
    else
      Or_error.error_s
        [%sexp
          "Executable differ"
          , { executable_with_ocaml_macro : Visa.Executable.t
            ; executable_with_visa_macro : Visa.Executable.t
            }]);
  [%expect {||}];
  ()
;;
