; dune file generated by '%{bin:bopkit} fmt gen-dune' -- do not edit.

(rule
 (with-stdout-to
  main.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:main.bop})))

(rule
 (alias fmt)
 (action
  (diff main.bop main.bop.pp.output)))
