(lang dune 3.14)

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

(using menhir 2.1)

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
   (>= 5.1))
  (ANSITerminal
   (>= 0.8.3))
  (appendable-list
   (and
    (>= v0.16)
    (< v0.17)))
  (auto-format
   (>= 0.0.2))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (bogue
   (>= 20221112))
  (command-unix-for-opam
   (>= 0.0.2))
  (core
   (and
    (>= v0.16)
    (< v0.17)))
  (core_unix
   (and
    (>= v0.16)
    (< v0.17)))
  (dune-site
   (>= 3.14))
  (error-log
   (>= 0.0.4))
  (fpath
   (>= 0.7.3))
  (fpath-extended
   (>= 0.0.3))
  (graphics
   (>= 5.1.2))
  (loc
   (>= 0.0.2))
  (mdx
   (>= 2.3))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.0.2))
  (pp
   (>= 1.2.0))
  (pp-extended
   (>= 0.0.2))
  (ppx_jane
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    (>= v0.16)
    (< v0.17)))
  (stdio
   (and
    (>= v0.16)
    (< v0.17)))
  (stdune
   (>= 3.14))
  (tsdl
   (>= 0.9.8))
  (tsdl-image
   (>= 0.6))))
