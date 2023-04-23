Checking various errors given by the analysis of the file, after the
parser but prior to outputing machine code.

  $ visa check file-not-found.asm
  File "file-not-found.asm", line 1, characters 0-0:
  Error: file-not-found.asm: No such file or directory.
  [1]

  $ for file in $(ls -1 *.asm | sort) ; do
  >   echo "================================: $file"
  >   visa check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: duplicated-constant.asm
  File "duplicated-constant.asm", line 2, characters 7-8:
  2 | define x #42
             ^
  Error: Multiple definition of constants is not allowed
  ((constant_name x))
  [1]
  ================================: duplicated-label.asm
  File "duplicated-label.asm", line 5, characters 0-5:
  5 | TAG:
  6 |   nop
  Error: Multiple definition of label is not allowed
  ((label TAG))
  [1]
  ================================: duplicated-macro-parameter.asm
  [0]
  ================================: duplicated-macro.asm
  File "duplicated-macro.asm", line 5, characters 6-9:
  5 | macro var y
            ^^^
  Error: Multiple definition of macros is not allowed
  ((macro_name var))
  [1]
  ================================: invalid-arguments.asm
  File "invalid-arguments.asm", line 2, characters 0-3:
  2 | nop #1
      ^^^
  Error: ("Invalid number of arguments"
   ((instruction_name NOP) (expects 0) (is_applied_to 1)))
  File "invalid-arguments.asm", line 3, characters 0-3:
  3 | add #1
      ^^^
  Error: ("Invalid number of arguments"
   ((instruction_name ADD) (expects 0) (is_applied_to 1)))
  File "invalid-arguments.asm", line 4, characters 4-6:
  4 | not $r
          ^^
  Error: ("Unbound parameter" ((parameter_name r)))
  File "invalid-arguments.asm", line 5, characters 10-16:
  5 | store R0, @label
                ^^^^^^
  Error: ("Invalid argument"
   ((instruction_name STORE) (arg 2) (expected Address)
    (applied_to (Label (label label)))))
  File "invalid-arguments.asm", line 6, characters 4-10:
  6 | jmp @label
          ^^^^^^
  Error: ("Undefined label" ((label label)))
  [1]
  ================================: label-without-instruction.asm
  File "label-without-instruction.asm", line 1, characters 0-4:
  1 | L1:
  2 | L2:
  Error: Label 'L1' was not followed by any instruction
  [1]
  ================================: undefined-macro.asm
  File "undefined-macro.asm", line 1, characters 6-9:
  1 | macro var
            ^^^
  Warning: Unused macro 'var'
  File "undefined-macro.asm", line 4, characters 0-3:
  4 | vra
      ^^^
  Error: Undefined macro 'vra'
  Hint: did you mean var?
  [1]
  ================================: unused-label.asm
  File "unused-label.asm", line 1, characters 0-7:
  1 | LABEL:
  2 |   sleep
  Warning: Unused label 'LABEL'
  [0]
  ================================: unused-macro-parameter.asm
  File "unused-macro-parameter.asm", line 1, characters 6-9:
  1 | macro var x, y
            ^^^
  Warning: Unused macro parameters
  ((macro_name var) (unused_parameters (y)))
  [0]
  ================================: unused-macro.asm
  File "unused-macro.asm", line 1, characters 6-9:
  1 | macro var
            ^^^
  Warning: Unused macro 'var'
  [0]
  ================================: unused-var.asm
  File "unused-var.asm", line 1, characters 7-10:
  1 | define var 42
             ^^^
  Warning: Unused constant 'var'
  [0]
