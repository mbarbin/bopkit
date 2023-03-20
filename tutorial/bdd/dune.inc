(rule
 (with-stdout-to
  check_dec7.bop.pp.output
  (bash "%{bin:bopkit} fmt file %{dep:check_dec7.bop}")))

(rule
 (alias fmt)
 (action
  (diff check_dec7.bop check_dec7.bop.pp.output)))

(rule
 (with-stdout-to
  check_starred.bop.pp.output
  (bash "%{bin:bopkit} fmt file %{dep:check_starred.bop}")))

(rule
 (alias fmt)
 (action
  (diff check_starred.bop check_starred.bop.pp.output)))
