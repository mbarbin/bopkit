(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type t =
  { lights : bool array
  ; switches : bool array
  ; pushes : bool array
  ; needs_redraw : bool ref
  }

let create ~num_lights ~num_switches ~num_pushes =
  { lights = Array.create ~len:num_lights false
  ; switches = Array.create ~len:num_switches false
  ; pushes = Array.create ~len:num_pushes false
  ; needs_redraw = ref true
  }
;;

(* Bopkit method for controlling lights *)
let light_method (t : t) =
  Bopkit_block.Method.create
    ~name:"light"
    ~input_arity:Remaining_bits
    ~output_arity:Empty
    ~f:(fun ~arguments ~input ~output:() ->
      let set_light i active =
        if Bool.( <> ) t.lights.(i) active
        then (
          t.needs_redraw.contents <- true;
          t.lights.(i) <- active)
      in
      (match arguments with
       | [] ->
         (* Set all lights *)
         let expected_length = Array.length t.lights in
         let input_length = Array.length input in
         if input_length <> expected_length
         then
           raise_s
             [%sexp
               "unexpected input length"
             , [%here]
             , { expected_length : int; input_length : int }];
         Array.iteri input ~f:(fun i active -> set_light i active)
       | [ index ] ->
         (* Set single light *)
         let index = Int.of_string index in
         if index < 0 || index >= Array.length t.lights
         then raise_s [%sexp "light index out of bounds", [%here], { index : int }];
         let input_length = Array.length input in
         let expected_length = 1 in
         if input_length <> expected_length
         then
           raise_s
             [%sexp
               "unexpected input length"
             , [%here]
             , { expected_length : int; input_length : int }];
         set_light index input.(0)
       | _ :: _ :: _ ->
         raise_s [%sexp "invalid arguments", [%here], { arguments : string list }]);
      ())
;;

(* Generic bopkit method for reading button states *)
let button_method (t : t) ~name ~which_state_array =
  Bopkit_block.Method.create
    ~name
    ~input_arity:Empty
    ~output_arity:Output_buffer
    ~f:(fun ~arguments ~input:() ~output ->
      let state_array = which_state_array t in
      let output_button active = Buffer.add_char output (if active then '1' else '0') in
      match arguments with
      | [] -> Array.iter state_array ~f:output_button
      | [ index ] ->
        let index = Int.of_string index in
        if index < 0 || index >= Array.length state_array
        then
          raise_s
            [%sexp "button index out of bounds", [%here], { name : string; index : int }];
        output_button state_array.(index)
      | _ :: _ :: _ ->
        raise_s [%sexp "invalid arguments", [%here], { arguments : string list }])
;;

(* Main bopkit method - does nothing but required by protocol *)
let main_method (_ : t) =
  Bopkit_block.Method.main
    ~input_arity:Empty
    ~output_arity:Empty
    ~f:(fun ~input:() ~output:() -> ())
;;

let needs_redraw (t : t) = t.needs_redraw
let lights (t : t) = t.lights
let switches (t : t) = t.switches
let pushes (t : t) = t.pushes

let create_methods (t : t) =
  [ light_method t
  ; button_method t ~name:"push" ~which_state_array:(fun s -> s.pushes)
  ; button_method t ~name:"switch" ~which_state_array:(fun s -> s.switches)
  ]
;;

let bopkit_block t =
  Bopkit_block.create
    ~name:"bopboard"
    ~main:(main_method t)
    ~methods:(create_methods t)
    ~is_multi_threaded:true
    ()
;;
