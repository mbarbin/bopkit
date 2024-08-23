(lang dune 3.16)

(name bopkit)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin")

(source
 (github mbarbin/bopkit))

(documentation "https://mbarbin.github.io/bopkit/")

(using dune_site 0.1)

(using mdx 0.4)

(using menhir 3.0)

(cram enable)

(package
 (name bopkit)
 (synopsis "An educational project for digital circuits programming")
 (sites
  (share stdlib)
  (share bopboard)
  (libexec stdbin))
 (depends
  (ocaml
   (>= 5.2))
  (ANSITerminal
   (>= 0.8.3))
  (appendable-list
   (and
    (>= v0.17)
    (< v0.18)))
  (auto-format
   (>= 0.0.11))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (base_quickcheck
   (and
    (>= v0.17)
    (< v0.18)))
  (cmdliner
   (= 1.3.0))
  (commandlang
   (>= 0.0.2))
  (commandlang-to-cmdliner
   (>= 0.0.2))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (core_unix
   (and
    (>= v0.17)
    (< v0.18)))
  (dune-site
   (>= 3.16))
  (err0
   (>= 0.0.2))
  (err0-handler
   (>= 0.0.2))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.0.9))
  (graphics
   (>= 5.1.2))
  (loc0
   (>= 0.1.0))
  (mdx
   (>= 2.4))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.0.8))
  (pp
   (>= 1.2.0))
  (pp-extended
   (>= 0.0.2))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_fields_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_js_style
   (and
    :dev
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))
  (tsdl
   (>= 0.9.8))
  (tsdl-image
   (>= 0.6))))

(package
 (name subleq)
 (synopsis "Bopkit subleq project")
 (depends
  (ocaml
   (>= 5.2))
  (ANSITerminal
   (>= 0.8.3))
  (appendable-list
   (and
    (>= v0.17)
    (< v0.18)))
  (auto-format
   (>= 0.0.11))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (base_quickcheck
   (and
    (>= v0.17)
    (< v0.18)))
  (bopkit
   (= :version))
  (cmdliner
   (= 1.3.0))
  (commandlang
   (>= 0.0.2))
  (commandlang-to-cmdliner
   (>= 0.0.2))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (core_unix
   (and
    (>= v0.17)
    (< v0.18)))
  (dune-site
   (>= 3.16))
  (err0
   (>= 0.0.2))
  (err0-handler
   (>= 0.0.2))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.0.9))
  (graphics
   (>= 5.1.2))
  (loc0
   (>= 0.1.0))
  (mdx
   (>= 2.4))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.0.8))
  (pp
   (>= 1.2.0))
  (pp-extended
   (>= 0.0.2))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_fields_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_js_style
   (and
    :dev
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))))

(package
 (name visa)
 (synopsis "Bopkit visa project")
 (depends
  (ocaml
   (>= 5.2))
  (ANSITerminal
   (>= 0.8.3))
  (appendable-list
   (and
    (>= v0.17)
    (< v0.18)))
  (auto-format
   (>= 0.0.11))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (base_quickcheck
   (and
    (>= v0.17)
    (< v0.18)))
  (bopkit
   (= :version))
  (cmdliner
   (= 1.3.0))
  (commandlang
   (>= 0.0.2))
  (commandlang-to-cmdliner
   (>= 0.0.2))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (core_unix
   (and
    (>= v0.17)
    (< v0.18)))
  (dune-site
   (>= 3.16))
  (err0
   (>= 0.0.2))
  (err0-handler
   (>= 0.0.2))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.0.9))
  (graphics
   (>= 5.1.2))
  (loc0
   (>= 0.1.0))
  (mdx
   (>= 2.4))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.0.8))
  (pp
   (>= 1.2.0))
  (pp-extended
   (>= 0.0.2))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_fields_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_js_style
   (and
    :dev
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))))

(package
 (name bopkit-tests)
 (synopsis "Tests for [bopkit]")
 (depends
  (ocaml
   (>= 5.2))
  (ANSITerminal
   (>= 0.8.3))
  (appendable-list
   (and
    (>= v0.17)
    (< v0.18)))
  (auto-format
   (>= 0.0.11))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (base_quickcheck
   (and
    (>= v0.17)
    (< v0.18)))
  (cmdliner
   (= 1.3.0))
  (commandlang
   (>= 0.0.2))
  (commandlang-to-cmdliner
   (>= 0.0.2))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (core_unix
   (and
    (>= v0.17)
    (< v0.18)))
  (dune-site
   (>= 3.16))
  (err0
   (>= 0.0.2))
  (err0-handler
   (>= 0.0.2))
  (expect_test_helpers_core
   (and
    (>= v0.17)
    (< v0.18)))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.0.9))
  (graphics
   (>= 5.1.2))
  (loc0
   (>= 0.1.0))
  (mdx
   (>= 2.4))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.0.8))
  (pp
   (>= 1.2.0))
  (pp-extended
   (>= 0.0.2))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_expect
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_fields_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_js_style
   (and
    :dev
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))
  (tsdl
   (>= 0.9.8))
  (tsdl-image
   (>= 0.6))))
