Hello

  $ echo '00001011101' | bopkit bdd checker --AD 4 --WL 7 -f starred.txt --no

  $ echo '00001011100' | bopkit bdd checker --AD 4 --WL 7 -f starred.txt --no
  Conflict for bdd at addr '0000' (0)
  Expected = '101*1*1'
  Received = '1011100'
  ("External block exception" ((name bdd-checker) (index_cycle 1))
   ((line 00001011100))
   (TEST_FAILURE ((address 0000) (expected 101*1*1) (received 1011100))))
  [1]

  $ bopkit simu check_starred.bop --num-counter-cycles 1 -o

  $ bopkit simu -n 1024 check_dec7.bop -o
