let%expect_test "7 segments" =
  for digit = 0 to 9 do
    print_string (Seven_segment_code.to_ascii ~digit)
  done;
  [%expect
    {|
     --
    |  |

    |  |
     --


       |

       |


     --
       |
     --
    |
     --

     --
       |
     --
       |
     --


    |  |
     --
       |


     --
    |
     --
       |
     --

     --
    |
     --
    |  |
     --

     --
       |

       |


     --
    |  |
     --
    |  |
     --

     --
    |  |
     --
       |
     -- |}]
;;
