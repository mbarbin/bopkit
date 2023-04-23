Simply check that the bop files have no errors.

  $ for file in $(ls -1 *.bop | sort) ; do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: calendar-output.bop
  [0]
  ================================: div10.bop
  [0]
  ================================: main.bop
  [0]
  ================================: visa.bop
  [0]
