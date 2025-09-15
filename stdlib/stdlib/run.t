Check that the files don't have errors in them.

  $ for file in $(ls -1 *.bop); do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: stdlib.bop
  File "stdlib.bop", line 266, characters 0-3:
  266 | CM2(in) = (s, r)
        ^^^
  Warning: Unused block 'CM2'.
  
  File "stdlib.bop", line 158, characters 0-6:
  158 | Equals(a, b) = s
        ^^^^^^
  Warning: Unused block 'Equals'.
  
  File "stdlib.bop", line 241, characters 0-9:
  241 | FullAdder(a, b, c) = (s, r)
        ^^^^^^^^^
  Warning: Unused block 'FullAdder'.
  
  File "stdlib.bop", line 315, characters 0-7:
  315 | Posedge(c) = en
        ^^^^^^^
  Warning: Unused block 'Posedge'.
  
  File "stdlib.bop", line 252, characters 0-3:
  252 | Var(set, en) = get
        ^^^
  Warning: Unused block 'Var'.
  [0]
