Check that the files don't have errors in them.

  $ for file in $(ls -1 *.bop); do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: stdlib.bop
  File "stdlib.bop", line 259, characters 0-3:
  259 | CM2(in) = (s, r)
        ^^^
  Warning: Unused block 'CM2'.
  File "stdlib.bop", line 151, characters 0-6:
  151 | Equals(a, b) = s
        ^^^^^^
  Warning: Unused block 'Equals'.
  File "stdlib.bop", line 234, characters 0-9:
  234 | FullAdder(a, b, c) = (s, r)
        ^^^^^^^^^
  Warning: Unused block 'FullAdder'.
  File "stdlib.bop", line 308, characters 0-7:
  308 | Posedge(c) = en
        ^^^^^^^
  Warning: Unused block 'Posedge'.
  File "stdlib.bop", line 245, characters 0-3:
  245 | Var(set, en) = get
        ^^^
  Warning: Unused block 'Var'.
  [0]
