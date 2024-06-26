; dune file generated by '%{bin:bopkit} fmt gen-dune' -- do not edit.

(rule
 (with-stdout-to
  any-block.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:any-block.bop})))

(rule
 (alias fmt)
 (action
  (diff any-block.bop any-block.bop.pp.output)))

(rule
 (with-stdout-to
  any-input.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:any-input.bop})))

(rule
 (alias fmt)
 (action
  (diff any-input.bop any-input.bop.pp.output)))

(rule
 (with-stdout-to
  any-loop-index.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:any-loop-index.bop})))

(rule
 (alias fmt)
 (action
  (diff any-loop-index.bop any-loop-index.bop.pp.output)))

(rule
 (with-stdout-to
  any-output.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:any-output.bop})))

(rule
 (alias fmt)
 (action
  (diff any-output.bop any-output.bop.pp.output)))

(rule
 (with-stdout-to
  any-param.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:any-param.bop})))

(rule
 (alias fmt)
 (action
  (diff any-param.bop any-param.bop.pp.output)))

(rule
 (with-stdout-to
  any-unused-var.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:any-unused-var.bop})))

(rule
 (alias fmt)
 (action
  (diff any-unused-var.bop any-unused-var.bop.pp.output)))

(rule
 (with-stdout-to
  any-used-var.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:any-used-var.bop})))

(rule
 (alias fmt)
 (action
  (diff any-used-var.bop any-used-var.bop.pp.output)))

(rule
 (with-stdout-to
  arg-fun-int.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:arg-fun-int.bop})))

(rule
 (alias fmt)
 (action
  (diff arg-fun-int.bop arg-fun-int.bop.pp.output)))

(rule
 (with-stdout-to
  block-arity-2.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:block-arity-2.bop})))

(rule
 (alias fmt)
 (action
  (diff block-arity-2.bop block-arity-2.bop.pp.output)))

(rule
 (with-stdout-to
  block-arity.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:block-arity.bop})))

(rule
 (alias fmt)
 (action
  (diff block-arity.bop block-arity.bop.pp.output)))

(rule
 (with-stdout-to
  conflicting-connection.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:conflicting-connection.bop})))

(rule
 (alias fmt)
 (action
  (diff conflicting-connection.bop conflicting-connection.bop.pp.output)))

(rule
 (with-stdout-to
  conflicting-unused.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:conflicting-unused.bop})))

(rule
 (alias fmt)
 (action
  (diff conflicting-unused.bop conflicting-unused.bop.pp.output)))

(rule
 (with-stdout-to
  cyclic-define.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:cyclic-define.bop})))

(rule
 (alias fmt)
 (action
  (diff cyclic-define.bop cyclic-define.bop.pp.output)))

(rule
 (with-stdout-to
  duplicated-fun-param.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:duplicated-fun-param.bop})))

(rule
 (alias fmt)
 (action
  (diff duplicated-fun-param.bop duplicated-fun-param.bop.pp.output)))

(rule
 (with-stdout-to
  duplicated-input.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:duplicated-input.bop})))

(rule
 (alias fmt)
 (action
  (diff duplicated-input.bop duplicated-input.bop.pp.output)))

(rule
 (with-stdout-to
  duplicated-output.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:duplicated-output.bop})))

(rule
 (alias fmt)
 (action
  (diff duplicated-output.bop duplicated-output.bop.pp.output)))

(rule
 (with-stdout-to
  duplicated-param.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:duplicated-param.bop})))

(rule
 (alias fmt)
 (action
  (diff duplicated-param.bop duplicated-param.bop.pp.output)))

(rule
 (with-stdout-to
  duplicated-ram.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:duplicated-ram.bop})))

(rule
 (alias fmt)
 (action
  (diff duplicated-ram.bop duplicated-ram.bop.pp.output)))

(rule
 (with-stdout-to
  duplicated-rom.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:duplicated-rom.bop})))

(rule
 (alias fmt)
 (action
  (diff duplicated-rom.bop duplicated-rom.bop.pp.output)))

(rule
 (with-stdout-to
  duplicated-unused.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:duplicated-unused.bop})))

(rule
 (alias fmt)
 (action
  (diff duplicated-unused.bop duplicated-unused.bop.pp.output)))

(rule
 (with-stdout-to
  external-nested-arity.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:external-nested-arity.bop})))

(rule
 (alias fmt)
 (action
  (diff external-nested-arity.bop external-nested-arity.bop.pp.output)))

(rule
 (with-stdout-to
  freevar-define.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:freevar-define.bop})))

(rule
 (alias fmt)
 (action
  (diff freevar-define.bop freevar-define.bop.pp.output)))

(rule
 (with-stdout-to
  freevar-external.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:freevar-external.bop})))

(rule
 (alias fmt)
 (action
  (diff freevar-external.bop freevar-external.bop.pp.output)))

(rule
 (with-stdout-to
  freevar-index.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:freevar-index.bop})))

(rule
 (alias fmt)
 (action
  (diff freevar-index.bop freevar-index.bop.pp.output)))

(rule
 (with-stdout-to
  freevar-unused.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:freevar-unused.bop})))

(rule
 (alias fmt)
 (action
  (diff freevar-unused.bop freevar-unused.bop.pp.output)))

(rule
 (with-stdout-to
  fun-param-arity.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:fun-param-arity.bop})))

(rule
 (alias fmt)
 (action
  (diff fun-param-arity.bop fun-param-arity.bop.pp.output)))

(rule
 (with-stdout-to
  input-as-output.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:input-as-output.bop})))

(rule
 (alias fmt)
 (action
  (diff input-as-output.bop input-as-output.bop.pp.output)))

(rule
 (with-stdout-to
  invalid-funarg-2.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:invalid-funarg-2.bop})))

(rule
 (alias fmt)
 (action
  (diff invalid-funarg-2.bop invalid-funarg-2.bop.pp.output)))

(rule
 (with-stdout-to
  invalid-funarg-3.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:invalid-funarg-3.bop})))

(rule
 (alias fmt)
 (action
  (diff invalid-funarg-3.bop invalid-funarg-3.bop.pp.output)))

(rule
 (with-stdout-to
  invalid-funarg-4.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:invalid-funarg-4.bop})))

(rule
 (alias fmt)
 (action
  (diff invalid-funarg-4.bop invalid-funarg-4.bop.pp.output)))

(rule
 (with-stdout-to
  invalid-funarg.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:invalid-funarg.bop})))

(rule
 (alias fmt)
 (action
  (diff invalid-funarg.bop invalid-funarg.bop.pp.output)))

(rule
 (with-stdout-to
  invalid-pipe-arity.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:invalid-pipe-arity.bop})))

(rule
 (alias fmt)
 (action
  (diff invalid-pipe-arity.bop invalid-pipe-arity.bop.pp.output)))

(rule
 (with-stdout-to
  memory-file-not-found.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:memory-file-not-found.bop})))

(rule
 (alias fmt)
 (action
  (diff memory-file-not-found.bop memory-file-not-found.bop.pp.output)))

(rule
 (with-stdout-to
  memory-too-long.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:memory-too-long.bop})))

(rule
 (alias fmt)
 (action
  (diff memory-too-long.bop memory-too-long.bop.pp.output)))

(rule
 (with-stdout-to
  nested-block-size.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:nested-block-size.bop})))

(rule
 (alias fmt)
 (action
  (diff nested-block-size.bop nested-block-size.bop.pp.output)))

(rule
 (with-stdout-to
  nested-output-size.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:nested-output-size.bop})))

(rule
 (alias fmt)
 (action
  (diff nested-output-size.bop nested-output-size.bop.pp.output)))

(rule
 (with-stdout-to
  only-funparam.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:only-funparam.bop})))

(rule
 (alias fmt)
 (action
  (diff only-funparam.bop only-funparam.bop.pp.output)))

(rule
 (with-stdout-to
  only-param.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:only-param.bop})))

(rule
 (alias fmt)
 (action
  (diff only-param.bop only-param.bop.pp.output)))

(rule
 (with-stdout-to
  output-not-assigned.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:output-not-assigned.bop})))

(rule
 (alias fmt)
 (action
  (diff output-not-assigned.bop output-not-assigned.bop.pp.output)))

(rule
 (with-stdout-to
  param-arity.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:param-arity.bop})))

(rule
 (alias fmt)
 (action
  (diff param-arity.bop param-arity.bop.pp.output)))

(rule
 (with-stdout-to
  pipe-nested-arity.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:pipe-nested-arity.bop})))

(rule
 (alias fmt)
 (action
  (diff pipe-nested-arity.bop pipe-nested-arity.bop.pp.output)))

(rule
 (with-stdout-to
  primitive-arity-2.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:primitive-arity-2.bop})))

(rule
 (alias fmt)
 (action
  (diff primitive-arity-2.bop primitive-arity-2.bop.pp.output)))

(rule
 (with-stdout-to
  primitive-arity.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:primitive-arity.bop})))

(rule
 (alias fmt)
 (action
  (diff primitive-arity.bop primitive-arity.bop.pp.output)))

(rule
 (with-stdout-to
  ram-arity-2.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:ram-arity-2.bop})))

(rule
 (alias fmt)
 (action
  (diff ram-arity-2.bop ram-arity-2.bop.pp.output)))

(rule
 (with-stdout-to
  ram-arity.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:ram-arity.bop})))

(rule
 (alias fmt)
 (action
  (diff ram-arity.bop ram-arity.bop.pp.output)))

(rule
 (with-stdout-to
  redefining-primitive.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:redefining-primitive.bop})))

(rule
 (alias fmt)
 (action
  (diff redefining-primitive.bop redefining-primitive.bop.pp.output)))

(rule
 (with-stdout-to
  rom-arity-2.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:rom-arity-2.bop})))

(rule
 (alias fmt)
 (action
  (diff rom-arity-2.bop rom-arity-2.bop.pp.output)))

(rule
 (with-stdout-to
  rom-arity.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:rom-arity.bop})))

(rule
 (alias fmt)
 (action
  (diff rom-arity.bop rom-arity.bop.pp.output)))

(rule
 (with-stdout-to
  type-clash.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:type-clash.bop})))

(rule
 (alias fmt)
 (action
  (diff type-clash.bop type-clash.bop.pp.output)))

(rule
 (with-stdout-to
  unbound-unused.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unbound-unused.bop})))

(rule
 (alias fmt)
 (action
  (diff unbound-unused.bop unbound-unused.bop.pp.output)))

(rule
 (with-stdout-to
  unknown-block.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unknown-block.bop})))

(rule
 (alias fmt)
 (action
  (diff unknown-block.bop unknown-block.bop.pp.output)))

(rule
 (with-stdout-to
  unknown-distribution-include.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unknown-distribution-include.bop})))

(rule
 (alias fmt)
 (action
  (diff
   unknown-distribution-include.bop
   unknown-distribution-include.bop.pp.output)))

(rule
 (with-stdout-to
  unknown-include.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unknown-include.bop})))

(rule
 (alias fmt)
 (action
  (diff unknown-include.bop unknown-include.bop.pp.output)))

(rule
 (with-stdout-to
  unknown-parametrized-block.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unknown-parametrized-block.bop})))

(rule
 (alias fmt)
 (action
  (diff
   unknown-parametrized-block.bop
   unknown-parametrized-block.bop.pp.output)))

(rule
 (with-stdout-to
  unused-block.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unused-block.bop})))

(rule
 (alias fmt)
 (action
  (diff unused-block.bop unused-block.bop.pp.output)))

(rule
 (with-stdout-to
  unused-bus.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unused-bus.bop})))

(rule
 (alias fmt)
 (action
  (diff unused-bus.bop unused-bus.bop.pp.output)))

(rule
 (with-stdout-to
  unused-fun-param.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unused-fun-param.bop})))

(rule
 (alias fmt)
 (action
  (diff unused-fun-param.bop unused-fun-param.bop.pp.output)))

(rule
 (with-stdout-to
  unused-param.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unused-param.bop})))

(rule
 (alias fmt)
 (action
  (diff unused-param.bop unused-param.bop.pp.output)))

(rule
 (with-stdout-to
  unused-signal.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:unused-signal.bop})))

(rule
 (alias fmt)
 (action
  (diff unused-signal.bop unused-signal.bop.pp.output)))

(rule
 (with-stdout-to
  used-unused.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:used-unused.bop})))

(rule
 (alias fmt)
 (action
  (diff used-unused.bop used-unused.bop.pp.output)))

(rule
 (with-stdout-to
  used-var-not-assigned.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:used-var-not-assigned.bop})))

(rule
 (alias fmt)
 (action
  (diff used-var-not-assigned.bop used-var-not-assigned.bop.pp.output)))

(rule
 (with-stdout-to
  write-input.bop.pp.output
  (run %{bin:bopkit} fmt file %{dep:write-input.bop})))

(rule
 (alias fmt)
 (action
  (diff write-input.bop write-input.bop.pp.output)))
