  $ for num in `seq 1 4`; do
  >   file="ar8-$num.input"
  >   img="ar8-$num.img"
  >   echo "===================================: $file"
  >   subleq simulate --ar 8 $file > $img
  >   code=$?
  >   diff $img "ar8-$num.output"
  >   echo "[${code}]"
  > done
  ===================================: ar8-1.input
  Subleq simulator: running...
  [ ;-) ] Program terminated after 989 steps. IM 40.23 % diff.
  [0]
  ===================================: ar8-2.input
  Subleq simulator: running...
  [ ;-) ] Program terminated after 501 steps. IM 36.62 % diff.
  [0]
  ===================================: ar8-3.input
  Subleq simulator: running...
  [ ;-) ] Program terminated after 80 steps. IM 10.64 % diff.
  [0]
  ===================================: ar8-4.input
  Subleq simulator: running...
  [ ;-) ] Program terminated after 398 steps. IM 25.59 % diff.
  [0]
