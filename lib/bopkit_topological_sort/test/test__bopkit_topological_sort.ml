(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module T = struct
  type key = string

  type t =
    { name : string
    ; parents : string list
    }

  let key t = t.name
  let parents t = Appendable_list.of_list t.parents
end

let%expect_test "sort" =
  let test nodes =
    Err.For_test.protect (fun () ->
      let nodes =
        List.map
          (Bopkit_topological_sort.sort (module T) (module String) nodes)
          ~f:(fun node -> node.name)
      in
      print_s [%sexp (nodes : string list)];
      ())
  in
  test [];
  [%expect {| () |}];
  test [ { name = "a"; parents = [] } ];
  [%expect {| (a) |}];
  test [ { name = "a"; parents = [ "b" ] } ];
  [%expect {| (a) |}];
  test
    [ { name = "a"; parents = [ "b" ] }
    ; { name = "b"; parents = [] }
    ; { name = "c"; parents = [ "a" ] }
    ];
  [%expect {| (b a c) |}];
  test
    [ { name = "a"; parents = [ "b" ] }
    ; { name = "b"; parents = [ "c" ] }
    ; { name = "e"; parents = [ "f" ] }
    ; { name = "c"; parents = [ "a" ] }
    ; { name = "f"; parents = [] }
    ];
  [%expect {| (c b a f e) |}];
  test
    [ { name = "a"; parents = [ "b" ] }
    ; { name = "a"; parents = [] }
    ; { name = "b"; parents = [] }
    ; { name = "c"; parents = [ "a" ] }
    ];
  [%expect {| (a b c) |}];
  ()
;;
