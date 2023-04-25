  $ for num in `seq 1 4`; do
  >   file="ar4-$num.input"
  >   img="ar4-$num.img"
  >   echo "===================================: $file"
  >   subleq simulate -ar 4 $file > $img
  >   code=$?
  >   diff $img "ar4-$num.output"
  >   echo "[${code}]"
  > done
  ===================================: ar4-1.input
  Subleq simulator: running...
  [ ;-) ] Program terminated after 4 steps. IM 12.50 % diff.
  [0]
  ===================================: ar4-2.input
  Subleq simulator: running...
  [ ;-) ] Program terminated after 33 steps. IM 43.75 % diff.
  [0]
  ===================================: ar4-3.input
  Subleq simulator: running...
  [ ;-) ] Program terminated after 7 steps. IM 12.50 % diff.
  [0]
  ===================================: ar4-4.input
  Subleq simulator: running...
  [ ;-) ] Program terminated after 18 steps. IM 43.75 % diff.
  [0]
