bopkit process exec evaluates the *.bpp file provided, and then acts as a
pipe01 application. The architecture of the process is set using the
[-N] paramter, from then on all variables are expected to have N bits.
The size of the input expected is then equals to (N * #V) where #V is
the number of parameters of the function.

  $ bopkit counter -N 4 -c 16 --ni 2> /dev/null | bopkit process exec -f sp1.bpp -N 2
  00
  10
  01
  11
  00
  01
  01
  00
  00
  10
  00
  10
  00
  01
  00
  01

  $ bopkit counter -N 8 -c 64 --ni 2> /dev/null | bopkit process exec -f sp1.bpp -N 4 2> /dev/null
  0011
  1011
  0111
  1111
  0000
  1000
  0100
  1100
  0010
  1010
  0110
  1110
  0001
  1001
  0101
  1101
  0011
  0111
  0111
  0000
  0000
  0100
  0100
  0010
  0010
  0110
  0110
  0001
  0001
  0101
  0101
  0011
  0011
  1011
  0000
  1000
  0000
  1000
  0010
  1010
  0010
  1010
  0001
  1001
  0001
  1001
  0011
  1011
  0011
  0111
  0000
  0100
  0000
  0100
  0010
  0110
  0010
  0110
  0001
  0101
  0001
  0101
  0011
  0111

  $ bopkit counter -N 4 -c 16 --ni 2> /dev/null | bopkit process exec -f sp2.bpp -N 4 2> /dev/null
  1111
  0111
  1011
  0011
  1101
  0101
  1001
  0001
  1110
  0110
  1010
  0010
  1100
  0100
  1000
  0000

  $ bopkit counter -N 3 -c 8 --ni 2> /dev/null | bopkit process exec -f sp2.bpp -N 3 2> /dev/null
  111
  011
  101
  001
  110
  010
  100
  000

  $ bopkit process exec -f runtime-error.bpp -N 1 <<EOF
  > 11
  > 01
  > 0
  0
  1
  Error: Aborted execution
  Error: Unexpected input length.
  ((expected_length 2) (input_length 1) (input 0))
  [123]

  $ echo "111" | bopkit process exec -f runtime-error.bpp -N 1
  Error: Aborted execution
  Error: Unexpected input length.
  ((expected_length 2) (input_length 3) (input 111))
  [123]
