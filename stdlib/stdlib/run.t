Check that the files don't have errors in them.

  $ for file in $(ls -1 *.bop); do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: stdlib.bop
  File "stdlib.bop", line 263, characters 0-3:
  263 | CM2(in) = (s, r)
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
  File "stdlib.bop", line 312, characters 0-7:
  312 | Posedge(c) = en
        ^^^^^^^
  Warning: Unused block 'Posedge'.
  File "stdlib.bop", line 244, characters 0-5:
  244 | RegMC(en, set) = get
        ^^^^^
  Warning: Unused block 'RegMC'.
  [0]
