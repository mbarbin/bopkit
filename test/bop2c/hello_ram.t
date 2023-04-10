Checking that bop2c handles RAM memories correctly.
The interface of the circuit is:
READ-ADDR(2)-WRITE-ADDR(2)-WRITE(1)-DATA(4)

Let's start first by reading all the cells.

  $ ./hello_ram.exe <<EOF
  > 000000000
  > 100000000
  > 010000000
  > 110000000
  0001
  0010
  0100
  1000

Then, we'll write some values into the cells, and read them back.

  $ ./hello_ram.exe <<EOF
  > 000011000
  > 001010100
  > 000110010
  > 001110001
  > 000000000
  > 100000000
  > 010000000
  > 110000000
  0000
  0000
  0000
  0000
  1000
  0100
  0010
  0001
