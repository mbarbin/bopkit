We check the netlists present in this directory, and stop just before
the execution. The files are expected to be accepted without raising
any analysis error. We do not check for runtime errors.

  $ for file in $(ls -1 *.bop | sort) ; do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: cyclic-include-a.bop
  [0]
  ================================: cyclic-include-b.bop
  [0]
  ================================: define-order.bop
  [0]
  ================================: duplicated-block.bop
  [0]
  ================================: duplicated-parametrized-block.bop
  [0]
  ================================: eval-funarg-1.bop
  [0]
  ================================: eval-funarg-2.bop
  [0]
  ================================: eval-funarg-3.bop
  [0]
  ================================: external-nested-arity-specified.bop
  File "calc.bop", line 1, characters 0-0:
  Error: calc.bop: No such file or directory.
  [1]
  ================================: memory-too-short.bop
  [0]
  ================================: pipe-nested-arity-specified.bop
  [0]
  ================================: ram-rom.bop
  [0]
  ================================: unused-external.bop
  [0]
  ================================: unused-parameter.bop
  [0]
  ================================: using-any.bop
  [0]
