Checking various errors given by the analysis of the file, after the
parser but prior to entering its execution.

  $ bopkit process exec -f file-not-found.bpp -N 2
  File "file-not-found.bpp", line 1, characters 0-0:
  Error: file-not-found.bpp: No such file or directory.
  [1]

  $ for file in $(ls -1 *.bpp | sort) ; do
  >   echo "================================: $file"
  >   bopkit process exec -f $file -N 2
  >   code=$?
  >   echo "[${code}]"
  > done
  ================================: arity-error.bpp
  File "arity-error.bpp", line 3, characters 6-8:
  3 |   p = /\ x
            ^^
  Error: Operator '/\' has arity 2 but is applied to 1 argument
  File "arity-error.bpp", line 4, characters 8-11:
  4 |   q = o not p
              ^^^
  Error: Operator 'not' has arity 1 but is applied to 2 arguments
  [1]
  ================================: unassigned-output.bpp
  File "unassigned-output.bpp", line 5, characters 10-12:
  5 |   p = q - 4v
                ^^
  Error: Variable '4v' is read before assignment
  File "unassigned-output.bpp", line 6, characters 7-8:
  6 | output z, p, u
             ^
  Error: Variable 'z' is read before assignment
  File "unassigned-output.bpp", line 6, characters 13-14:
  6 | output z, p, u
                   ^
  Error: Variable 'u' is read before assignment
  [1]
  ================================: unassigned-var.bpp
  File "unassigned-var.bpp", line 5, characters 10-12:
  5 |   p = q - 4v
                ^^
  Error: Variable '4v' is read before assignment
  [1]
  ================================: undefined-operator.bpp
  File "undefined-operator.bpp", line 2, characters 8-11:
  2 |   p = x ~!~ y
              ^^^
  Error: operator '~!~' is not defined
  File "undefined-operator.bpp", line 3, characters 8-11:
  3 |   q = x +!+ y
              ^^^
  Error: operator '+!+' is not defined
  [1]

