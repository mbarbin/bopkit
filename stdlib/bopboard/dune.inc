; dune file generated by '%{bin:bopkit} fmt gen-dune' -- do not edit.

(rule
 (with-stdout-to
  bopboard.bop.pp.output
  (bash "%{bin:bopkit} fmt file %{dep:bopboard.bop}")))

(rule
 (alias fmt)
 (action
  (diff bopboard.bop bopboard.bop.pp.output)))