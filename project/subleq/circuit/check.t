Simply check that the bop files have no errors.

  $ for file in $(ls -1 *.bop | sort) ; do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: main.bop
  [0]
  ================================: subleq.bop
  [0]
