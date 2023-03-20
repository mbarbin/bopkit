Hello

  $ bopkit simu -counter-input -n 4 counter-input.bop
     Cycle | a[0] a[1] | b
         0 | 0 0 | 0
         1 | 1 0 | 1
         2 | 0 1 | 1
         3 | 1 1 | 1

  $ bopkit simu counter-input.bop -num-counter-cycles 2 -show-input
     Cycle | a[0] a[1] | b
         0 | 0 0 | 0
         1 | 1 0 | 1
         2 | 0 1 | 1
         3 | 1 1 | 1
         4 | 0 0 | 0
         5 | 1 0 | 1
         6 | 0 1 | 1
         7 | 1 1 | 1

  $ bopkit simu counter-input.bop -num-counter-cycles 2 \
  >   -show-input -output-only-on-change
  Error parsing command line:
  
    Cannot pass more than one of these: 
      -show-input
      -output-only-on-change
  
  For usage information, run
  
    bopkit simu -help
  
  [1]

  $ bopkit simu counter-input.bop -num-counter-cycles 2 \
  >   -output-only-on-change
  0
  1
  0
  1
