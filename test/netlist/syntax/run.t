The files in this directory are not auto-formatted. We test here
indeed the auto-formatting, as well as syntax errors that we desire to
monitor in tests.

  $ bopkit fmt test
  ================================: block.bop
  #define N 2
  
  Main(a, b[0], c:[N], d[0..N], e:[-N]) = (f:[N]:[N], g:[N][0..N - 1])
  where
    for i = 0 to N - 1
      for j = 0 to N - 1
        f[i][j] = Id(c[i]);
        g[j][i] = Id(And(d[j], c[i]));
      end for;
    end for;
  end where;
  ================================: comments-above-define.bop
  /* Checking behavior of comments placements in the presence of #define
   * constructs.
   */
  #define M "macro"
  ================================: comments-above-for.bop
  #define N 4
  
  // Check behavior of comments placements above loops.
  external with_loops "./with_loops.exe"
    // Such as this one!
    for i = 1 to 3
      def "m%{i}"
      // In the case of for loop, there might be tail comments.
    end for;
    // External blocks may have tail comments too.
  end external;
  
  B(a:[N]) = b:[N]
  where
    // And this one too!
    for i = 0 to N - 1
      b[i] = Not(a[i]);
      // Hello tail comment.
    end for;
  end where;
  ================================: comments-above-if.bop
  #define N 4
  
  // Check behavior of comments placements above if statements.
  external with_loops "./with_loops.exe"
    // Such as this one!
    if N mod 2 == 0 then
      def "m%{i}"
    end if;
  end external;
  
  B(a:[N]) = b:[N]
  where
    // And this one too!
    if N mod 2 == 0 then
      b[i] = Not(a[i]);
    else
      b[i] = Id(a[i]);
    end if;
  end where;
  ================================: comments-above-include.bop
  /* As we added support for comments in the parser+pp, we monitored
   * with tests like this one how comments are picked up at different
   * part of a netlist file.
   */
  
  // This netlist has comment before the first [#include] construct
  /**
   * It even has documentation comments !
   */
  #include <stdlib.bop>
  ================================: comments-and-blocks.bop
  #define N 4
  
  /**
   * Comments may be documenting blocks.
   */
  B(a:[N]) = b:[N]
  where
    // In the body of blocks there might be comments too,
    for i = 0 to N - 1
      b[i] = Not(a[i]);
      // Tail comments in loops as well.
    end for;
    if N == 0 then
      $extra();
      // Testing if tail comments.
    end if;
    if N == 0 then
      $extra_then();
      // Then tail comment.
    else
      $extra_else();
      // Tail comment.
    end if;
    /* Comments at the end of the body are block tail
     * comments.
     */
  end where;
  
  // Without forgetting comments at the end of the file.
  ================================: comments-include-define.bop
  /* Checking behavior of comments placements in the presence of both constructs:
   * - [#inline]
   * - [#define]
   */
  #include <stdlib.bop>
  
  /* Another above another [#include].
   */
  #include "my-file.bop"
  
  // Some other comment above a macro.
  #define M "macro"
  
  /**
   * And another one.
   */
  #define N "n_macro"
  ================================: define.bop
  #define N 0
  #define p 1
  #define s "Hello"
  #define X ( N == 0 ? "x" : "y" )
  #define Z ( p + N * 10 < 1 ? 42 : 43 )
  ================================: empty.bop
  ================================: empty_block.bop
  Main() = ()
  where
  end where;
  ================================: external-arity.bop
  File "external-arity.bop", line 8, characters 16-17:
  8 |   out = $cal.add[2](a, b);
                      ^
  Error:  syntax error.
  ================================: external-call.bop
  #define N 4
  
  external calc "./calc.exe -N %{N}"
    /**
     * Documentation for the add method.
     */
    def add
  
    /**
     * Documentation for the mult method.
     */
    def mult
  end external;
  
  external pulse "./pulse.exe"
  
  external viewer "./viewer.exe"
  
  Calc_add(a:[N], b:[N], select) = out:[N]
  where
    tmp:[N] = Not[N]($calc[N](a:[N]));
    add:[N] = $calc.add("a", "b", a:[N], b:[N]);
    mult:[N] = $calc.mult("a", "b", a:[N], b:[N]);
    out:[N] = Mux[N](select, add:[N], mult:[N]);
  end where;
  
  Pulse() = s
  where
    a = $pulse("a");
    b = Not($pulse[1]("b"));
    s = And(a, b);
  
    // Because external can often take input without returning outputs,
    // we allow for the equal sign to be omitted.
    $viewer(a, b, s);
  end where;
  ================================: external-method-name.bop
  #define N 4
  
  external buttons "./buttons.exe -N %{N}"
  
  Bloc(a:[N]) = ()
  where
    for i = 0 to N - 1
      $buttons."PUSH_%{i}"(a[i]);
    end for;
  end where;
  ================================: external.bop
  #define N 4
  
  external calc "./calc.exe -N %{N}"
  
  external [ Attr1, Attr2 ] with_attr "./with_attr.exe"
  
  external with_methods "%{PATH}/with_methods.exe -N %{N}"
    def m1
    def [ A1, A2 ] m2
    def "m3"
  end external;
  
  external with_loops "./with_loops.exe"
    for i = 1 to 3
      if i mod 2 == 0 then
        for j = i
          def "m%{i}"
        end for;
      end if;
    end for;
  end external;
  ================================: funargs.bop
  And[N](a:[N]) = s
  where
    s = FoldLeft[N]<"And", "Map", "Id">(a:[N]);
  end where;
  ================================: include-dash-file.bop
  File "include-dash-file.bop", line 2, characters 16-17:
  2 | #include <stdlib-file-with-dashes.bop>
                      ^
  Error:  syntax error.
  ================================: include.bop
  #include "user-file.bop"
  #include <distribution_file.bop>
  ================================: io-vars.bop
  #define N 2
  
  Main(a, b[0], c:[N], d[0..N], e:[-N]) = (f:[N]:[N], g:[N][0..N - 1])
  where
  end where;
  ================================: memory.bop
  #define N 4
  
  RAM myram (2, 2) = text { 00111100 }
  ROM myrom (2, N) = file("rom.bin")
  ================================: nested-comments.bop
  // This test shows an issue with pp (or likely the underlying fmt)
  // hvbox does not take into account the newline in its understanding
  // of what fits and what doesn't. If the comment is longer, the behavior
  // is different. I don't know how to work around it at the moment.
  B(___Un, ___state) = ___then___Deux
  where
    ___then___Deux =
      Mux[1](// N is only visible if global
        Vdd(), ___Un, ___state);
  end where;
  
  B(___Un, ___state) = ___then___Deux
  where
    ___then___Deux =
      Mux[1](
        // N is only visible if global. Hey now the comment is longer!
        Vdd(),
        ___Un,
        ___state);
  end where;
  ================================: nested-variables.bop
  // Checking how nested calls and comments are handled.
  Bloc(a:[7], b:[10]) = out
  where
    out =
      Mux(
        // Hello nested comment.
        a[0],
        Mux(
          a[1],
          Mux(
            a[2],
            Mux(a[3], Mux(a[4], Not(a[5]), Vdd()), Not(a[4])),
            Mux(a[3], Mux(a[4], Vdd(), a[5]), Mux(a[4], Not(a[5]), Gnd()))),
          Mux(a[2], Mux(a[3], Vdd(), Not(a[4])), a[5])),
        Mux(
          a[1],
          Mux(
            a[2],
            Mux(
              a[3],
              Vdd(),
              Mux(
                a[4],
                Not(a[5]),
                // We can communicate a particular grouping to the printer
                // by adding extra PARENs around the variables to group.
                And[10](
                  (b[0], b[1]),
                  (b[2], b[3], b[4], b[5]),
                  b[6],
                  b[7],
                  b[8],
                  b[9],
                  b[10]))),
            Mux(
              a[3],
              Mux(a[4], Mux(a[5], Gnd(), Not(a[6])), Mux(a[5], Vdd(), a[6])),
              a[4])),
          Mux(
            a[2],
            Mux(a[3], Vdd(), Mux(a[4], Mux(a[5], a[6], Vdd()), a[5])),
            Mux(
              /* Hey, this comment is about the a[3] that's right below.
               * There're so many things that we could say about it.
               */
              a[3],
              Mux(a[4], Mux(a[5], a[6], Vdd()), Mux(a[5], Gnd(), a[6])),
              Gnd()))));
  end where;
  ================================: pipe-arity.bop
  File "pipe-arity.bop", line 5, characters 12-13:
  5 |   out = pipe[2]("./external.exe", f);
                  ^
  Error:  syntax error.
  ================================: pipe.bop
  A(a, b) = out
  where
    out = external("./external.exe", a, b);
  end where;
  
  B() = out
  where
    out = external("./external.exe");
  end where;
  
  C(e, f) = out
  where
    out = And(e, external[1]("./external.exe", f));
  end where;
  ================================: text-memory.bop
  // At the moment, the memory text syntax does not round-trip. It was
  // designed without auto-formatting in mind, thus it's likely this
  // needs to be adjusted.
  RAM r (10, 10) = text {
    // Perhaps authorizing a form of comment and keeping only a few
    // authorized characters in the text portion.
    00|00|00|01|10|00|11
    01|10|00|01|10|00|11
    11|01|01|01|10|00|11
  }
  ================================: with-unused.bop
  #define N 2
  
  A(a, c) = b
  with unused = c
  where
    b = Id(a);
  end where;
  
  B(a, c:[8], d) = b
  with unused = (d, c[1..7])
  where
    b = And(a, c[0]);
  end where;
