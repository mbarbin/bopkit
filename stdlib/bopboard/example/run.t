Check that the files don't have errors in them.

  $ for file in $(ls -1 *.bop); do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: bit_shift.bop
  [0]
  ================================: lights.bop
  [0]
  ================================: lights_bdd.bop
  [0]
  ================================: ram.bop
  [0]
