(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

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
