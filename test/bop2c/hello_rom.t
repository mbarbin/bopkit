Checking that bop2c handles ROM memories correctly.

  $ ./hello_rom.exe <<EOF
  > 1
  Input line too short.
  Expected 2 bits - got 1.
  [1]

  $ bopkit counter -N 2 -c 4 --ni | ./hello_rom.exe
  0001
  0010
  0100
  1000
