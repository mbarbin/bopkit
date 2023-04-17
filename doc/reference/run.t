We check the netlists present in this directory, and stop just before
the execution. The files are expected to be accepted without raising
any analysis error. We do not check for runtime errors.

  $ for file in $(ls -1 *.bop | sort) ; do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: and2_recursive.bop
  [0]
  ================================: one-of-each.bop
  [0]
  ================================: parametrized-block.bop
  [0]
