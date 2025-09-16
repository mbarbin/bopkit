(lang dune 3.20)

(name bopkit)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin <opensource@mbarbin.org>")

(source
 (github mbarbin/bopkit))

(documentation "https://mbarbin.github.io/bopkit/")

(using dune_site 0.1)

(using mdx 0.4)

(using menhir 3.0)

(implicit_transitive_deps false)

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
   (>= v0.17))
  (auto-format
   (>= 0.0.17))
  (base
   (>= v0.17))
  (base_quickcheck
   (>= v0.17))
  (cmdlang
   (>= 0.0.9))
  (comments-parser
   (>= 0.2.3))
  (core
   (>= v0.17))
  (dune-site
   (>= 3.20))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.2.0))
  (loc
   (>= 0.2.2))
  (mdx
   (>= 2.4))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.2.3))
  (pp
   (>= 2.0.0))
  (pp-extended
   (>= 0.0.2))
  (pplumbing
   (>= 0.0.14))
  (ppx_compare
   (>= v0.17))
  (ppx_enumerate
   (>= v0.17))
  (ppx_fields_conv
   (>= v0.17))
  (ppx_hash
   (>= v0.17))
  (ppx_here
   (>= v0.17))
  (ppx_let
   (>= v0.17))
  (ppx_sexp_conv
   (>= v0.17))
  (ppx_sexp_value
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (stdio
   (>= v0.17))
  (stdune
   (>= 3.20))
  (tsdl
   (>= 1.1.0))
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
   (>= v0.17))
  (auto-format
   (>= 0.0.17))
  (base
   (>= v0.17))
  (base_quickcheck
   (>= v0.17))
  (bopkit
   (= :version))
  (cmdlang
   (>= 0.0.9))
  (core
   (>= v0.17))
  (dune-site
   (>= 3.20))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.2.0))
  (loc
   (>= 0.2.2))
  (mdx
   (>= 2.4))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.2.3))
  (pp
   (>= 2.0.0))
  (pp-extended
   (>= 0.0.2))
  (pplumbing
   (>= 0.0.14))
  (ppx_compare
   (>= v0.17))
  (ppx_enumerate
   (>= v0.17))
  (ppx_fields_conv
   (>= v0.17))
  (ppx_hash
   (>= v0.17))
  (ppx_here
   (>= v0.17))
  (ppx_let
   (>= v0.17))
  (ppx_sexp_conv
   (>= v0.17))
  (ppx_sexp_value
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (stdio
   (>= v0.17))
  (stdune
   (>= 3.20))))

(package
 (name visa)
 (synopsis "Bopkit visa project")
 (depends
  (ocaml
   (>= 5.2))
  (ANSITerminal
   (>= 0.8.3))
  (appendable-list
   (>= v0.17))
  (auto-format
   (>= 0.0.17))
  (base
   (>= v0.17))
  (base_quickcheck
   (>= v0.17))
  (bopkit
   (= :version))
  (cmdlang
   (>= 0.0.9))
  (core
   (>= v0.17))
  (dune-site
   (>= 3.20))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.2.0))
  (loc
   (>= 0.2.2))
  (mdx
   (>= 2.4))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.2.3))
  (pp
   (>= 2.0.0))
  (pp-extended
   (>= 0.0.2))
  (pplumbing
   (>= 0.0.14))
  (ppx_compare
   (>= v0.17))
  (ppx_enumerate
   (>= v0.17))
  (ppx_fields_conv
   (>= v0.17))
  (ppx_hash
   (>= v0.17))
  (ppx_here
   (>= v0.17))
  (ppx_let
   (>= v0.17))
  (ppx_sexp_conv
   (>= v0.17))
  (ppx_sexp_value
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (stdio
   (>= v0.17))
  (stdune
   (>= 3.20))))

(package
 (name bopkit-tests)
 (synopsis "Tests for [bopkit]")
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (and
    :with-dev-setup
    (= 0.27.0)))
  (ANSITerminal
   (>= 0.8.3))
  (appendable-list
   (>= v0.17))
  (auto-format
   (>= 0.0.17))
  (base
   (>= v0.17))
  (base_quickcheck
   (>= v0.17))
  (bopkit
   (= :version))
  (cmdlang
   (>= 0.0.9))
  (comments-parser
   (>= 0.2.3))
  (core
   (>= v0.17))
  (dune-site
   (>= 3.20))
  (expect_test_helpers_core
   (>= v0.17))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.2.0))
  (loc
   (>= 0.2.2))
  (mdx
   (>= 2.4))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.2.3))
  (pp
   (>= 2.0.0))
  (pp-extended
   (>= 0.0.2))
  (pplumbing
   (>= 0.0.14))
  (ppx_compare
   (>= v0.17))
  (ppx_enumerate
   (>= v0.17))
  (ppx_expect
   (>= v0.17))
  (ppx_fields_conv
   (>= v0.17))
  (ppx_hash
   (>= v0.17))
  (ppx_here
   (>= v0.17))
  (ppx_js_style
   (and
    :with-dev-setup
    (>= v0.17)))
  (ppx_let
   (>= v0.17))
  (ppx_sexp_conv
   (>= v0.17))
  (ppx_sexp_value
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (stdio
   (>= v0.17))
  (stdune
   (>= 3.20))
  (subleq
   (= :version))
  (tsdl
   (>= 1.1.0))
  (tsdl-image
   (>= 0.6))
  (visa
   (= :version))))

(package
 (name bopkit-dev)
 (synopsis
  "Package to regroup dev targets for the bopkit project, documentation, and more")
 (allow_empty) ; The package is attached to mdx stanzas however dune doesn't see it.
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (and
    :with-dev-setup
    (= 0.27.0)))
  (ANSITerminal
   (>= 0.8.3))
  (appendable-list
   (>= v0.17))
  (auto-format
   (>= 0.0.17))
  (base
   (>= v0.17))
  (base_quickcheck
   (>= v0.17))
  (bopkit
   (= :version))
  (bopkit-tests
   (= :version))
  (cmdlang
   (>= 0.0.9))
  (comments-parser
   (>= 0.2.3))
  (core
   (>= v0.17))
  (dune-site
   (>= 3.20))
  (expect_test_helpers_core
   (>= v0.17))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.2.0))
  (loc
   (>= 0.2.2))
  (mdx
   (>= 2.4))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.2.3))
  (pp
   (>= 2.0.0))
  (pp-extended
   (>= 0.0.2))
  (pplumbing
   (>= 0.0.14))
  (ppx_compare
   (>= v0.17))
  (ppx_enumerate
   (>= v0.17))
  (ppx_expect
   (>= v0.17))
  (ppx_fields_conv
   (>= v0.17))
  (ppx_hash
   (>= v0.17))
  (ppx_here
   (>= v0.17))
  (ppx_js_style
   (and
    :with-dev-setup
    (>= v0.17)))
  (ppx_let
   (>= v0.17))
  (ppx_sexp_conv
   (>= v0.17))
  (ppx_sexp_value
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (stdio
   (>= v0.17))
  (stdune
   (>= 3.20))
  (subleq
   (= :version))
  (tsdl
   (>= 1.1.0))
  (tsdl-image
   (>= 0.6))
  (visa
   (= :version))
  (sherlodoc
   (and
    :with-doc
    (>= 0.2)))))
