Check that the files don't have errors in them.

  $ for file in $(ls -1 *.bop); do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: example.bop
  [0]
  ================================: pulse.bop
  File "pulse.bop", line 1, characters 0-0:
  Error: Project has no main block.
  [123]
