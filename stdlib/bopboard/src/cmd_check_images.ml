(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let main =
  Command.make
    ~summary:"Check that all required images are present."
    (let open Command.Std in
     let+ images =
       Arg.pos_all Param.string ~docv:"IMG" ~doc:"Images to include in the check."
     in
     let required_images =
       Image.all |> List.map ~f:Image.basename |> Set.of_list (module String)
     in
     let available_images = images |> Set.of_list (module String) in
     if [%equal: Set.M(String).t] required_images available_images
     then (
       Stdlib.Printf.printf "Required images equals to available images.\n";
       print_s [%sexp (required_images : Set.M(String).t)])
     else (
       let missing_images = Set.diff required_images available_images in
       if not (Set.is_empty missing_images)
       then (
         Stdlib.Printf.printf "[!] The following images are missing:\n";
         print_s [%sexp (missing_images : Set.M(String).t)]);
       let unused_images = Set.diff available_images required_images in
       if not (Set.is_empty unused_images)
       then (
         Stdlib.Printf.printf "[!] The following images are unused:\n";
         print_s [%sexp (unused_images : Set.M(String).t)]);
       Stdlib.exit 1))
;;
