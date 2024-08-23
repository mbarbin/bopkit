Parameters may be overridden from the command line.

  $ bopkit simu --num-counter-cycles 1 parameter-override.bop
     Cycle | a[0][0] a[1][0] | s
         0 | 0 0 | 0
         1 | 1 0 | 0
         2 | 0 1 | 0
         3 | 1 1 | 1

  $ bopkit simu --num-counter-cycles 1 parameter-override.bop --parameter 'N 3'
  bopkit: option '--parameter': Invalid parameter argument. Expected
          'name=value'.
  Usage: bopkit simu [OPTION]… FILE
  Try 'bopkit simu --help' or 'bopkit --help' for more information.
  [124]

  $ bopkit simu --num-counter-cycles 1 parameter-override.bop --parameter 'N=3'
     Cycle | a[0][0] a[1][0] a[2][0] | s
         0 | 0 0 0 | 0
         1 | 1 0 0 | 0
         2 | 0 1 0 | 0
         3 | 1 1 0 | 0
         4 | 0 0 1 | 0
         5 | 1 0 1 | 0
         6 | 0 1 1 | 0
         7 | 1 1 1 | 1

  $ bopkit simu --num-counter-cycles 1 parameter-override.bop --parameter 'N=1' --parameter 'M=2'
     Cycle | a[0][0] a[0][1] | s
         0 | 0 0 | 0
         1 | 1 0 | 0
         2 | 0 1 | 0
         3 | 1 1 | 1

Currently there are no checks that the parameter is actually useful, and in
general unused parameters aren't raised by the compiler.

  $ bopkit simu --num-counter-cycles 1 parameter-override.bop --parameter 'U=1'
     Cycle | a[0][0] a[1][0] | s
         0 | 0 0 | 0
         1 | 1 0 | 0
         2 | 0 1 | 0
         3 | 1 1 | 1
