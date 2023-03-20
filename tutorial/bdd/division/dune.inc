(rule
 (with-stdout-to
  divcheck.bop.pp.output
  (bash "%{bin:bopkit} fmt file %{dep:divcheck.bop}")))

(rule
 (alias fmt)
 (action
  (diff divcheck.bop divcheck.bop.pp.output)))

(rule
 (with-stdout-to
  generate.bop.pp.output
  (bash "%{bin:bopkit} fmt file %{dep:generate.bop}")))

(rule
 (alias fmt)
 (action
  (diff generate.bop generate.bop.pp.output)))
