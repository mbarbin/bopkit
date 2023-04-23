When testing circuit with multiple blocks defined in it, the default main is the
last block of the file. This can be overridden from the command line.

This can be useful to test specific blocks of a file without having to write
another dedicated circuit for it. This test covers the basics of that
functionality.

  $ bopkit simu main-override.bop -num-counter-cycles 1
     Cycle | a b | s
         0 | 0 0 | 0
         1 | 1 0 | 1
         2 | 0 1 | 1
         3 | 1 1 | 1

  $ bopkit simu main-override.bop -num-counter-cycles 1 -main Hello_an
  Error: Failed to find main block name 'Hello_an'.
  Hint: did you mean Hello_and or Hello_or?
  [1]

  $ bopkit simu main-override.bop -num-counter-cycles 1 -main Hello_and
     Cycle | a b | s
         0 | 0 0 | 0
         1 | 1 0 | 0
         2 | 0 1 | 0
         3 | 1 1 | 1

  $ bopkit simu main-override.bop -num-counter-cycles 1 -main Hello_or
     Cycle | a b | s
         0 | 0 0 | 0
         1 | 1 0 | 1
         2 | 0 1 | 1
         3 | 1 1 | 1
