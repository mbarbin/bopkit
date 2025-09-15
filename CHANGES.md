## 0.3.5 (2025-09-15)

### Changed

- Add license headers (#35, #36, @mbarbin).
- Cosmetic refactor in cli help & doc pages (9fdaf39d, @mbarbin).
- Upgrade to more recent dependencies (502ee9b9, #31, #34, @mbarbin).
- Upgrade to more recent `pplumbing` dep (#29, #30, @mbarbin).

### Fixed

- Fix missing test dep (3afb9c57, @mbarbin).

## 0.3.4 (2025-04-25)

### Changed

- Rename `_syntax` components into `_parser` (#28, @mbarbin).
- Require `dune.3.18` (#27, @mbarbin).
- Use `format-dune-file` stanza (#26, @mbarbin).

### Fixed

- Handle `loc` deprecations (cfc30b18, @mbarbin).

## 0.3.3 (2025-03-10)

### Changed

- Switched from `pp-log` to `pplumbing`.

### Fixed

- Replace `pipe-stdout` constructs by `bash` when they are expected to be interactive (#22, @mbarbin).

## 0.3.2 (2024-09-29)

### Changed

- Upgrade to `cmdlang.0.0.5`.

## 0.3.1 (2024-09-07)

### Changed

- Upgrade to latest `cmdlang`.

## 0.3.0 (2024-08-23)

### Changed

- Switch from `Error_log` to `Err` for error handling.
- Internal refactors, switch from `Core` to `Base` in assorted places.
- Split main packages into separate smaller ones.
- Switch to `cmdlang` with `cmdliner` as a backend for all commands. Breaking changes:
  - Flags and named command line arguments now have 2 '--' instead of 1.
  - Exit code changes, using now cmdliner default conventions (123, 124, 125).

## 0.2.9 (2024-07-26)

### Added

- Added dependabot config for automatically upgrading action files.

### Changed

- Upgrade `ppxlib` to `0.33` - activate unused items warnings.
- Upgrade `ocaml` to `5.2`.
- Upgrade `dune` to `3.16`.
- Upgrade base & co to `0.17`.

## 0.2.8 (2024-05-05)

### Removed

- Moved `visa-debugger` into a [standalone repo](https://github.com/mbarbin/visa-debugger), with the goal of removing `bogue` from the `bopkit`'s dependencies.

## 0.2.7 (2024-03-13)

### Changed

- Upgrade `fpath-base` to `0.0.9` (was renamed from `fpath-extended`).
- Uses `expect-test-helpers` (reduce core dependencies).
- Upgrade `mdx` to `2.4`. Add `skip` to non-executable ocaml sections.
- Run `ppx_js_style` as a linter & make it a `dev` dependency.
- Upgrade GitHub workflows `actions/checkout` to v4.
- In CI, specify build target `@all`, and add `@lint`.
- List ppxs instead of `ppx_jane`.

## 0.2.6 (2024-02-14)

### Changed

- Upgrade dune to `3.14`.
- Build the doc with sherlodoc available to enable the doc search bar.
- Clarify handling of deprecated aliases for primitives. Internal refactor only,
  no behavior change.

### Fixed

- Fixed behavior of the `GOF` instruction in the visa simulator.

## 0.2.5 (2024-02-09)

### Changed

- Internal changes related to the release process.
- Upgrade dune and internal dependencies.

## 0.2.4 (2024-01-18)

### Changed

- Internal changes related to build and release process.
- Rename most file path variables from [filename] to [path] and switch from type
  [string] to [Fpath.t] (#7, @mbarbin).
- Extract some libraries into their own packages to reuse in other projects:
  `auto-format`, `error-log`, `loc`, `parsing-utils` (#7, @mbarbin).

## 0.2.3 (2023-11-03)

### Changed

- Migrate Docusaurus config files to TypeScript.

### Fixed

- Fix `bopkit -version`. There are subtle differences between using
  `public_name` and `(install (section bin))` which I do not understand yet, but
  using the latter disables dune-build-info.

## 0.2.2 (2023-11-03)

### Changed

- Now generating opam file from dune-project.

### Fixed

- Use `command-unix-for-opam` to fix `-version` for all binaries.
- Fix dune-install invocation to locate shared files at runtime (#6).

## 0.2.1 (2023-11-02)

### Changed

- Change changelog format to be closer to dune-release's.
- Now building distribution with `dune-release`.
- Internal refactoring related to -open via flags.

### Fixed

- `bopkit -version` now prints the distribution version correctly.

## 0.2.0 (2023-10-30)

### Added

- Added docusaurus documentation website, publish to GitHub Pages.
- Added changelog.
- Added pretty-printers for all languages. Integrate it to dune-fmt.

### Changed

- Rename project from 'bebop' to 'bopkit'.
- Now building with dune.
- Make tests compatible with dune-promote mechanism.
- Standardize install procedure: now uses opam + dune-site.
- Migrate all parsers to Menhir.
- Rewrite the bopboard in OCaml using tsdl (it was in C and using SDL-1 which is now deprecated).
- Rewrite visa assembly tool from C to OCaml.
- Group executables into a single CLI named 'bopkit'.
- In external blocks, always use method_name as implementation_name, merge the two concepts.

### Fixed

- Fixed nondeterministic failure in visa assembler to machine-code. This was
  fixed as part of the rewrite to OCaml.

### Removed

- Removed bopipe and bopin. Replaced bpo and bpi files by external blocks construction in OCaml.
- Removed bop2vhdl. This was highly experimental and untested.
- Removed bop2xml. This wasn't used by any project.

## 0.1.1 (2007/2008)

Project didn't have a changelog then.
