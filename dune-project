(lang dune 3.17)

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
   (and
    (>= v0.17)
    (< v0.18)))
  (auto-format
   (>= 0.0.15))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (base_quickcheck
   (and
    (>= v0.17)
    (< v0.18)))
  (cmdlang
   (>= 0.0.9))
  (comments-parser
   (>= 0.2.3))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (dune-site
   (>= 3.17))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.1.2))
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
   (>= 0.0.9))
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
   (>= 3.17))
  (tsdl
   (>= 1.0.0))
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
   (>= 0.0.15))
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
  (cmdlang
   (>= 0.0.9))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (dune-site
   (>= 3.17))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.1.2))
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
   (>= 0.0.9))
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
   (>= 3.17))))

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
   (>= 0.0.15))
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
  (cmdlang
   (>= 0.0.9))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (dune-site
   (>= 3.17))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.1.2))
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
   (>= 0.0.9))
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
   (>= 3.17))))

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
   (and
    (>= v0.17)
    (< v0.18)))
  (auto-format
   (>= 0.0.15))
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
  (cmdlang
   (>= 0.0.9))
  (comments-parser
   (>= 0.2.3))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (dune-site
   (>= 3.17))
  (expect_test_helpers_core
   (and
    (>= v0.17)
    (< v0.18)))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.1.2))
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
   (>= 0.0.9))
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
    :with-dev-setup
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
   (>= 3.17))
  (subleq
   (= :version))
  (tsdl
   (>= 1.0.0))
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
   (and
    (>= v0.17)
    (< v0.18)))
  (auto-format
   (>= 0.0.15))
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
  (bopkit-tests
   (= :version))
  (cmdlang
   (>= 0.0.9))
  (comments-parser
   (>= 0.2.3))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (dune-site
   (>= 3.17))
  (expect_test_helpers_core
   (and
    (>= v0.17)
    (< v0.18)))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (graphics
   (>= 5.1.2))
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
   (>= 0.0.9))
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
    :with-dev-setup
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
   (>= 3.17))
  (subleq
   (= :version))
  (tsdl
   (>= 1.0.0))
  (tsdl-image
   (>= 0.6))
  (visa
   (= :version))))
