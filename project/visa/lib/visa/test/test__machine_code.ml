let%expect_test "operation" =
  let module Operation = Visa.Machine_code.For_testing.Operation in
  let test operation =
    let byte = Operation.to_byte operation in
    let operation' = Operation.of_byte byte |> Option.value_exn ~here:[%here] in
    if not ([%equal: Operation.t] operation operation')
    then
      raise_s
        [%sexp
          "Visa.Machine_code does not round-trip"
        , { byte : Visa.Machine_code.Byte.t
          ; operation : Operation.t
          ; operation' : Operation.t
          }];
    print_endline
      (sprintf
         "%20s : %s - opcode=%02d"
         (Sexp.to_string_mach [%sexp (operation : Operation.t)])
         (Visa.Machine_code.Byte.to_string byte)
         (Operation.op_code operation))
  in
  List.iter Operation.all ~f:test;
  [%expect
    (* $MDX part-begin=machineCodes *)
    {|
              Nop : 00000000 - opcode=00
            Sleep : 10000000 - opcode=01
              Add : 01000000 - opcode=02
              And : 11000000 - opcode=03
              Swc : 00100000 - opcode=04
              Cmp : 10100000 - opcode=05
           Not_R0 : 01100000 - opcode=06
           Not_R1 : 01101000 - opcode=06
              Gof : 11100000 - opcode=07
              Jmp : 00010000 - opcode=08
              Jmn : 10010000 - opcode=09
              Jmz : 01010000 - opcode=10
         Store_R0 : 11010000 - opcode=11
         Store_R1 : 11011000 - opcode=11
          Load_R0 : 00110100 - opcode=12
          Load_R1 : 00111100 - opcode=12
    Load_value_R0 : 00110000 - opcode=12
    Load_value_R1 : 00111000 - opcode=12 |}];
  (* $MDX part-end *)
  ()
;;
