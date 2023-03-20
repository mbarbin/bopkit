(lang dune 3.5)
(using dune_site 0.1)
(name bopkit)
(cram enable)
(using menhir 2.1)
(using mdx 0.2)

(package
 (name bopkit)
 (sites (share stdlib) (share bopboard) (libexec stdbin)))
