(lang dune 3.11)

(using dune_site 0.1)

(name bopkit)

(cram enable)

(using menhir 2.1)

(using mdx 0.2)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin")

(source
 (github mbarbin/bopkit))

(documentation "https://mbarbin.github.io/bopkit/")

(package
 (name bopkit)
 (synopsis "An educational project for digital circuits programming")
 (description "An educational project for digital circuits programming")
 (sites
  (share stdlib)
  (share bopboard)
  (libexec stdbin))
 (depends
  (ocaml
   (>= 5.1))
  (dune
   (>= 3.11))
  (dune-site
   (>= 3.11))
  (appendable-list
   (and
    (>= v0.16)
    (< v0.17)))
  (ANSITerminal
   (>= 0.8.3))
  (bogue
   (>= 20221112))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (core
   (and
    (>= v0.16)
    (< v0.17)))
  (core_unix
   (and
    (>= v0.16)
    (< v0.17)))
  (command-unix-for-opam
   (>= 0.0.1))
  (graphics
   (>= 5.1.2))
  (mdx
   (>= 2.2))
  (menhir
   (>= 20220210))
  (ppx_jane
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    (>= v0.16)
    (< v0.17)))
  (pp
   (>= 1.1.2))
  (stdio
   (and
    (>= v0.16)
    (< v0.17)))
  (stdune
   (>= 3.11))
  (tsdl
   (>= 0.9.8))
  (tsdl-image
   (>= 0.6))))
