By default, when a circuit does not expect any input, [simu] does not use stdin.

  $ bopkit simu empty-input.bop -n 4
     Cycle | | a
         0 | | 0
         1 | | 1
         2 | | 0
         3 | | 1

But when used with the option [-p], the execution behaves as an external block,
so it expects an empty line as input on each cycle.

  $ echo '0' | bopkit simu empty-input.bop -n 4 -p
  Error: Unexpected stdin input length.
  Input was "0" - length 1 - expected 0 char(s).
  [123]

  $ bopkit simu empty-input.bop -n 2 -p <<EOF
  > 
  > 
  0
  1

Similarly, when there are no outputs, the default behavior is to print nothing,
or to print the input if that's what's requested.

  $ bopkit simu empty-output.bop -n 2 --counter-input --show-input
     Cycle | s |
         0 | 0 |
         1 | 1 |

  $ bopkit simu empty-output.bop -n 2 --counter-input --output-only

But when [-p] is supplied, then empty lines have to be produced.

  $ bopkit simu empty-output.bop -n 2 --counter-input -p
  
  

The point for [-p] is for [bopkit simu] to work when invoked from another bop
file, as an external block, such as it is done in the file below:

  $ bopkit simu using-empty-output.bop -n 4 --counter-input
     Cycle | a | b
         0 | 0 | 1
         1 | 1 | 0
         2 | 0 | 1
         3 | 1 | 0
