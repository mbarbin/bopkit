Checking that the *.bop files compile OK as part of the runtest
target.

  $ for file in $(ls -1 *.bop | sort) ; do
  >   echo "================================: $file"
  >   bopkit check $file
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: main.bop
  [0]
  ================================: watch.bop
  [0]
  ================================: watch_with_bopboard.bop
  [0]
