; dune file generated by '%{bin:bopkit} fmt gen-dune' -- do not edit.

(rule
 (with-stdout-to
  hello-stdlib.bop.pp.output
  (bash "%{bin:bopkit} fmt file %{dep:hello-stdlib.bop}")))

(rule
 (alias fmt)
 (action
  (diff hello-stdlib.bop hello-stdlib.bop.pp.output)))

(rule
 (with-stdout-to
  hello.bop.pp.output
  (bash "%{bin:bopkit} fmt file %{dep:hello.bop}")))

(rule
 (alias fmt)
 (action
  (diff hello.bop hello.bop.pp.output)))