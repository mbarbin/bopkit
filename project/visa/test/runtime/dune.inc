; dune file generated by '%{bin:visa} fmt gen-dune' -- do not edit.

(rule
 (with-stdout-to
  constant.asm.pp.output
  (run %{bin:visa} fmt file %{dep:constant.asm})))

(rule
 (alias fmt)
 (action
  (diff constant.asm constant.asm.pp.output)))

(rule
 (with-stdout-to
  loop.asm.pp.output
  (run %{bin:visa} fmt file %{dep:loop.asm})))

(rule
 (alias fmt)
 (action
  (diff loop.asm loop.asm.pp.output)))

(rule
 (with-stdout-to
  minus.asm.pp.output
  (run %{bin:visa} fmt file %{dep:minus.asm})))

(rule
 (alias fmt)
 (action
  (diff minus.asm minus.asm.pp.output)))
