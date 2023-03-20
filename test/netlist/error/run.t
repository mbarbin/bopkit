Checking various errors given by the analysis of the file, after the
parser but prior to entering its execution.

  $ bopkit check freevar-index.bop
  File "freevar-index.bop", line 3, characters 5-10:
  3 | Main(a:[N]) = s
           ^^^^^
  Error: Unbound variable 'N'.
  [1]

  $ for file in $(ls -1 *.bop | sort) ; do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: any-block.bop
  File "any-block.bop", line 1, characters 0-1:
  1 | _(a) = b
      ^
  Error: Do not use '_' as a ident for a block, input or output.
  It is reserved for unused variables.
  [1]
  ================================: any-input.bop
  File "any-input.bop", line 1, characters 0-1:
  1 | A(_) = b
      ^
  Error: Do not use '_' as a ident for a block, input or output.
  It is reserved for unused variables.
  [1]
  ================================: any-loop-index.bop
  [0]
  ================================: any-output.bop
  File "any-output.bop", line 1, characters 0-1:
  1 | A() = _
      ^
  Error: Do not use '_' as a ident for a block, input or output.
  It is reserved for unused variables.
  [1]
  ================================: any-param.bop
  [0]
  ================================: any-used-var.bop
  File "any-used-var.bop", line 1, characters 0-1:
  1 | A(a) = c
      ^
  Error: Block variable '_' belongs to the block unused variables but it is
  used.
  [1]
  ================================: arg-fun-int.bop
  File "arg-fun-int.bop", line 1, characters 0-0:
  Error: Project has no main block.
  [1]
  ================================: block-arity-2.bop
  File "block-arity-2.bop", line 8, characters 2-17:
  8 |   c, d = A(a, b);
        ^^^^^^^^^^^^^^^
  Error: Block 'A' has 1 outputs but is connected to 2 variables.
  [1]
  ================================: block-arity.bop
  File "block-arity.bop", line 8, characters 2-11:
  8 |   b = A(a);
        ^^^^^^^^^
  Error: Block 'A' expects 2 inputs but is applied to 1 variables.
  [1]
  ================================: conflicting-connection.bop
  File "conflicting-connection.bop", line 1, characters 0-1:
  1 | A(a, b) = c
      ^
  Error: In block 'A': conflicting connections of block variable 'c'.
  Hint: A variable may appear at most once in the set of block variables that
  are connected to node outputs but it is here connected to the output of
  several nodes.
  [1]
  ================================: conflicting-unused.bop
  File "conflicting-unused.bop", line 1, characters 0-1:
  1 | A(a, b) = c
      ^
  Error: In block 'A': conflicting connections of block variable 'd'.
  Hint: A variable may appear at most once in the set of block variables that
  are connected to node outputs but it is here connected to the output of
  several nodes.
  [1]
  ================================: cyclic-define.bop
  File "cyclic-define.bop", line 5, characters 0-11:
  5 | #define V X
      ^^^^^^^^^^^
  Error: Unbound variable 'X'.
  [1]
  ================================: duplicated-fun-param.bop
  File "duplicated-fun-param.bop", line 1, characters 0-1:
  1 | A<f1, f1>(a) = b
      ^
  Error: Duplication of block functional parameter(s): 'f1'.
  [1]
  ================================: duplicated-input.bop
  File "duplicated-input.bop", line 1, characters 0-1:
  1 | A(a, a) = b
      ^
  Error: Duplicated block variable 'a'. Input/Output names should be unique.
  [1]
  ================================: duplicated-output.bop
  File "duplicated-output.bop", line 1, characters 0-1:
  1 | A(a) = (b, b)
      ^
  Error: Duplicated block variable 'b'. Input/Output names should be unique.
  [1]
  ================================: duplicated-param.bop
  File "duplicated-param.bop", line 1, characters 0-1:
  1 | A[N][N](a:[N]) = b:[N]
      ^
  Error: Duplication of block parameter(s) 'N'.
  [1]
  ================================: duplicated-ram.bop
  File "duplicated-ram.bop", line 2, characters 0-32:
  2 | RAM name (0, 5) = text { 00110 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: A memory with name 'name' is already defined.
  [1]
  ================================: duplicated-rom.bop
  File "duplicated-rom.bop", line 2, characters 0-32:
  2 | ROM name (0, 5) = text { 00110 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: A memory with name 'name' is already defined.
  [1]
  ================================: external-nested-arity.bop
  File "external-nested-arity.bop", line 9, characters 19-42:
  9 |   out:[N] = not[N]($calc.add(a:[N], b:[N]));
                         ^^^^^^^^^^^^^^^^^^^^^^^
  Error: Bopkit won't infer the output size of a nested external call.
  Hint: You can either place this call at toplevel, or add the output size
  explicitely using the appropriate syntax:
  Pipe     =>             pipe[N](...)
  External =>    $block.method[N](...)
  [1]
  ================================: freevar-define.bop
  File "freevar-define.bop", line 3, characters 0-31:
  3 | #define Z ( COND == 0 ? 0 : 1 )
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Unbound variable 'COND'.
  [1]
  ================================: freevar-external.bop
  File "freevar-external.bop", line 1, characters 0-34:
  1 | external calc "./calc.exe -N %{N}"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Unbound variable 'N'.
  [1]
  ================================: freevar-index.bop
  File "freevar-index.bop", line 3, characters 5-10:
  3 | Main(a:[N]) = s
           ^^^^^
  Error: Unbound variable 'N'.
  [1]
  ================================: freevar-unused.bop
  [0]
  ================================: fun-param-arity.bop
  File "fun-param-arity.bop", line 8, characters 2-16:
  8 |   b = P<not>(a);
        ^^^^^^^^^^^^^^
  Error: Block 'P<_>' expects 2 functional parameters but is applied to 1
  [1]
  ================================: input-as-output.bop
  File "input-as-output.bop", line 1, characters 0-1:
  1 | A(a) = a
      ^
  Error: Block variable 'a' is used but is not assigned to any node output.
  [1]
  ================================: invalid-funarg-2.bop
  File "invalid-funarg-2.bop", line 5, characters 2-13:
  5 |   b = fun(a);
        ^^^^^^^^^^^
  Error: Unknown block name '1'.
  Hint: did you mean Z, id, nZ, or or ~?
  [1]
  ================================: invalid-funarg-3.bop
  File "invalid-funarg-3.bop", line 5, characters 2-13:
  5 |   b = fun(a);
        ^^^^^^^^^^^
  Error: The primitive 'and' expects 2 inputs but is applied to 1 variables.
  [1]
  ================================: invalid-funarg-4.bop
  File "invalid-funarg-4.bop", line 3, characters 2-13:
  3 |   b = fun(a);
        ^^^^^^^^^^^
  Error: The primitive 'and' expects 2 inputs but is applied to 1 variables.
  [1]
  ================================: invalid-funarg.bop
  File "invalid-funarg.bop", line 3, characters 2-13:
  3 |   b = fun(a);
        ^^^^^^^^^^^
  Error: Unknown block name 'N'.
  Hint: did you mean Z, id, nZ, or or ~?
  [1]
  ================================: invalid-pipe-arity.bop
  File "invalid-pipe-arity.bop", line 3, characters 2-45:
  3 |   out = and(e, pipe[2]("./external.exe", f));
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: The primitive 'and' expects 2 inputs but is applied to 3 variables.
  [1]
  ================================: memory-file-not-found.bop
  File "memory-file-not-found.bop", line 1, characters 0-41:
  1 | ROM r (2, 2) = file("file-not-found.txt")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: "file-not-found.txt": memory file not found
  [1]
  ================================: memory-too-long.bop
  File "memory-too-long.bop", line 1, characters 0-31:
  1 | RAM r (0, 5) = text { 000|101 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Memory 'r' specification:
  Number of bits expected: 5 - given: 6
  [1]
  ================================: nested-block-size.bop
  File "nested-block-size.bop", line 14, characters 2-17:
  14 |   c = N(A(a, b));
         ^^^^^^^^^^^^^^^
  Error: Block 'N' expects 1 inputs but is applied to 2 variables.
  [1]
  ================================: nested-output-size.bop
  File "nested-output-size.bop", line 9, characters 2-19:
  9 |   c = not(A(a, b));
        ^^^^^^^^^^^^^^^^^
  Error: The primitive 'not' expects 1 inputs but is applied to 2 variables.
  [1]
  ================================: only-funparam.bop
  File "only-funparam.bop", line 1, characters 0-0:
  Error: Project has no main block.
  [1]
  ================================: only-param.bop
  File "only-param.bop", line 1, characters 0-0:
  Error: Project has no main block.
  [1]
  ================================: output-not-assigned.bop
  File "output-not-assigned.bop", line 1, characters 0-1:
  1 | A() = c
      ^
  Error: Block variable 'c' is used but is not assigned to any node output.
  [1]
  ================================: param-arity.bop
  File "param-arity.bop", line 8, characters 2-14:
  8 |   b = P[4](a);
        ^^^^^^^^^^^^
  Error: Block 'P[_]' expects 2 parameters but is applied to 1
  [1]
  ================================: pipe-nested-arity.bop
  File "pipe-nested-arity.bop", line 3, characters 15-40:
  3 |   out = and(e, pipe("./external.exe", f));
                     ^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: Bopkit won't infer the output size of a nested external call.
  Hint: You can either place this call at toplevel, or add the output size
  explicitely using the appropriate syntax:
  Pipe     =>             pipe[N](...)
  External =>    $block.method[N](...)
  [1]
  ================================: primitive-arity-2.bop
  File "primitive-arity-2.bop", line 3, characters 2-19:
  3 |   c, d = and(a, b);
        ^^^^^^^^^^^^^^^^^
  Error: The primitive 'and' has 1 outputs but is connected to 2 variables.
  [1]
  ================================: primitive-arity.bop
  File "primitive-arity.bop", line 3, characters 2-13:
  3 |   c = and(a);
        ^^^^^^^^^^^
  Error: The primitive 'and' expects 2 inputs but is applied to 1 variables.
  [1]
  ================================: ram-arity-2.bop
  File "ram-arity-2.bop", line 5, characters 2-44:
  5 |   o:[2] = ram_r(a:[2], a:[2], vdd(), b:[3]);
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: The primitive 'ram_r' has 3 outputs but is connected to 2 variables.
  [1]
  ================================: ram-arity.bop
  File "ram-arity.bop", line 5, characters 2-30:
  5 |   o:[3] = ram_r(a:[2], b:[3]);
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: The primitive 'ram_r' expects 8 inputs but is applied to 5 variables.
  [1]
  ================================: redefining-primitive.bop
  File "redefining-primitive.bop", line 1, characters 0-3:
  1 | and(a, b) = c
      ^^^
  Error: Invalid block name. 'and' is a primitive and cannot be redefined.
  [1]
  ================================: rom-arity-2.bop
  File "rom-arity-2.bop", line 5, characters 2-23:
  5 |   o:[2] = rom_r(a:[2]);
        ^^^^^^^^^^^^^^^^^^^^^
  Error: The primitive 'rom_r' has 3 outputs but is connected to 2 variables.
  [1]
  ================================: rom-arity.bop
  File "rom-arity.bop", line 5, characters 2-30:
  5 |   o:[3] = rom_r(a:[2], b:[3]);
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: The primitive 'rom_r' expects 2 inputs but is applied to 5 variables.
  [1]
  ================================: type-clash.bop
  File "type-clash.bop", line 5, characters 5-10:
  5 | Main(a:[X]) = s
           ^^^^^
  Error: Parameter 'X' is of type string but an int is expected
  [1]
  ================================: unknown-block.bop
  File "unknown-block.bop", line 3, characters 2-17:
  3 |   b = Unknown(a);
        ^^^^^^^^^^^^^^^
  Error: Unknown block name 'Unknown'.
  [1]
  ================================: unknown-distribution-include.bop
  File "unknown-distribution-include.bop", line 1, characters 0-29:
  1 | #include <file_not_found.bop>
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: "file_not_found.bop": included file not found.
  Hint: Try running `bopkit print-sites` to locate and inspect the directory
  where the stdlib files are installed on your machine.
  [1]
  ================================: unknown-include.bop
  File "file-not-found.bop", line 1, characters 0-0:
  Error: file-not-found.bop: No such file or directory.
  [1]
  ================================: unknown-parametrized-block.bop
  File "unknown-parametrized-block.bop", line 3, characters 2-20:
  3 |   b = Unknown[1](a);
        ^^^^^^^^^^^^^^^^^^
  Error: Unknown block name 'Unknown'.
  [1]
  ================================: unused-block.bop
  File "unused-block.bop", line 1, characters 0-1:
  1 | A(a) = b
      ^
  Warning: Unused block 'A'.
  [0]
  ================================: unused-bus.bop
  File "unused-bus.bop", line 1, characters 0-4:
  1 | Main(a, b:[2]) = s
      ^^^^
  Warning: Unused block variable 'b[0]'.
  Hint: You can suppress this warning by adding the variable name to the list
  of this block's unused variables: with unused = (... , b[0])
  File "unused-bus.bop", line 1, characters 0-4:
  1 | Main(a, b:[2]) = s
      ^^^^
  Warning: Unused block variable 'b[1]'.
  Hint: You can suppress this warning by adding the variable name to the list
  of this block's unused variables: with unused = (... , b[1])
  [0]
  ================================: unused-fun-param.bop
  [0]
  ================================: unused-param.bop
  [0]
  ================================: unused-signal.bop
  File "unused-signal.bop", line 1, characters 0-4:
  1 | Main(a, b) = s
      ^^^^
  Warning: Unused block variable 'b'.
  Hint: You can suppress this warning by adding the variable name to the list
  of this block's unused variables: with unused = (... , b)
  [0]
  ================================: used-unused.bop
  File "used-unused.bop", line 1, characters 0-1:
  1 | A(a) = c
      ^
  Error: Block variable 'b' belongs to the block unused variables but it is
  used.
  [1]
  ================================: used-var-not-assigned.bop
  File "used-var-not-assigned.bop", line 1, characters 0-1:
  1 | A() = b
      ^
  Error: Block variable 'c' is used but is not assigned to any node output.
  [1]
  ================================: write-input.bop
  File "write-input.bop", line 1, characters 0-1:
  1 | A(a, b) = c
      ^
  Error: In block 'A', input variable 'a' is connected to a node output. Block
  inputs should be read-only in the body the block.
  [1]
