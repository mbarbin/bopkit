Hello

  $ bopkit simu iii.bop --num-counter-cycles 2
     Cycle | i[0] i[1] i[2] | i
         0 | 0 0 0 | 0
         1 | 1 0 0 | 0
         2 | 0 1 0 | 0
         3 | 1 1 0 | 0
         4 | 0 0 1 | 0
         5 | 1 0 1 | 0
         6 | 0 1 1 | 0
         7 | 1 1 1 | 1
         8 | 0 0 0 | 0
         9 | 1 0 0 | 0
        10 | 0 1 0 | 0
        11 | 1 1 0 | 0
        12 | 0 0 1 | 0
        13 | 1 0 1 | 0
        14 | 0 1 1 | 0
        15 | 1 1 1 | 1

  $ bopkit simu cycle.bop
  File "cycle.bop", line 1, characters 0-0:
  Error: The circuit has a cycle.
  Hint: Below are some hints to try and find it:
  
  File "cycle.bop", line 2, characters 0-5:
  2 | Cycle(a, b) = s
      ^^^^^
  Error: In this block, these variables may create a dependency cycle:
  
    ..#0#.. = ..Id(..u..);
  
    ..u.. = ..And(..g..);
  
    ..g.. = ..Or(..#0#..);
  
  [123]
