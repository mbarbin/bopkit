<h1 align="center">
  <p align="center">Bopkit</p>
  <img
    src="https://github.com/mbarbin/bopkit/blob/assets/image/bopkit-logo.png?raw=true"
    width=512
    alt="Logo"
  />
</h1>

<p align="center">
  <a href="https://github.com/mbarbin/bopkit/actions/workflows/ci.yml"><img src="https://github.com/mbarbin/bopkit/workflows/ci/badge.svg" alt="CI Status"></a>
  <a href="https://github.com/mbarbin/bopkit/actions/workflows/deploy-doc.yml"><img src="https://github.com/mbarbin/bopkit/workflows/deploy-doc/badge.svg" alt="Deploy Doc Status"></a>
  <a href="https://github.com/mbarbin/bopkit/actions/workflows/build-odoc.yml"><img src="https://github.com/mbarbin/bopkit/workflows/build-odoc/badge.svg" alt="Build odoc Status"></a>
</p>

Welcome to Bopkit, an educational project that provides a description language
for programming synchronous digital circuits.

With Bopkit, you can express synchronous digital circuits, simulate them using
the Bopkit simulator, and convert your designs to standalone C executables or
hierarchical Verilog.

Bopkit also provides an interface for integrating external blocks written in
other languages. For example, you can use OCaml blocks for unit-testing, or
connect your circuits to user-friendly graphical devices such as the [Bopboard](stdlib/bopboard/) or
a [7-segment display](project/digital-watch/).

# ![ladybug ico](../assets/image/ladybug_32.ico?raw=true) Install

Please note that only installation from sources is currently supported. Clone
the repository, then build and install the code with dune:

```
dune build
dune install
```

# ![ladybug ico](../assets/image/ladybug_32.ico?raw=true) Documentation

Bopkit's documentation is published [here](https://mbarbin.github.io/bopkit). It
is built with [docusaurus](https://docusaurus.io/), an application developed by
Meta, Inc to create open source documentation websites.

# ![ladybug ico](../assets/image/ladybug_32.ico?raw=true) Tutorials

Check out our [tutorials](tutorial/) for an introduction to different parts of
Bopkit, and explore our more substantive [projects](project/), including a
digital watch, user-friendly graphical devices, and projects involving
microprocessors, assemblers and compilers. There's plenty of fun stuff there!

# ![ladybug ico](../assets/image/ladybug_32.ico?raw=true) Origin

The project originated in 2007 as a class assignment with Professor Jean
Vuillemin[^1]:

> Write a simulator for a hardware description language of your choice; use it
> to execute on a micro-processor of your design a binary code that will drive
> the display of a digital calendar.

Ocan Sankur and Mathieu Barbin teamed up to complete the project, implementing a
HDL based on a subset of the language 2Z[^2] used in the course notes, and
designing a micro-processor called visa.

After the assignment was completed, Bopkit grew into a fun tool box for
experimenting and playing around with various aspects of language implementation
in OCaml and digital circuit programming.

In 2023, Bopkit was rediscovered in the archives and was given a new lease of
life. The project was updated to work with modern tools and libraries, and
hosted on GitHub. It was a delightful journey down memory lane!

# ![ladybug ico](../assets/image/ladybug_32.ico?raw=true) Acknowledgments

We would like to express our gratitude to the following individuals:

* **Jean Vuillemin** for the class and assignment that sparked the beginning of
  this project.
* **Ocan Sankur** for co-authoring the initial assignment and for implementing
  the micro-processor visa with an early version of bopkit that had some rough
  edges.
* **Mehdi Bouaziz** for co-authoring the subleq project, which we implemented as
  a project for **David Naccache**'s class.
* **Marc Pouzet**[^3] for suggesting the addition of Mode-automata constructs to
  the language. We implemented this as a project for M. Pouzet's class with
  **Xun Gong**.
* **Patrick Cousot**[^4] for teaching the compilation class that served as the
  basis for the wml project.
* **Samuel Kvaalen** for the bopkit logo and developing the adorable bopboard.

In addition, we'd like to thank:

* The **Menhir** developers, for a smooth experience migrating our older
  ocamlyacc parsers into Menhir.
* The **Tsdl** programmers, for a smooth experience migrating the bopboard from
  C/SDL-1 to OCaml.
* **OpenAI**, for providing **ChatGPT** and the **DALL-E** tool. We used ChatGPT
  to improve some of the text in this project, and used DALL-E to generate some
  images in this project. OpenAI is a research organization focused on
  artificial intelligence. Learn more about ChatGPT and DALL-E at openai.com/.

[^1]:Jean Vuillemin, https://www.di.ens.fr/~jv/

[^2]: F. Bourdoncle, J. Vuillemin and G. Berry, The 2Z reference manual, PRL
report ??, Digital Equipment Corp., Paris Research Laboratory, 85, Av. Victor
Hugo. 92563 Rueil-Malmaison Cedex, France, 1994.

[^3]:Marc Pouzet, https://www.di.ens.fr/~pouzet/

[^4]:Patrick Cousot, https://cs.nyu.edu/~pcousot/
