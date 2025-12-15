(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Execution_result = struct
  type t =
    | Continue
    | End_of_input
    | Runtime_error of Error.t
end

let execute_instruction ~architecture ~memory ~instruction : Execution_result.t =
  match (instruction : Interpreted_code.Instruction.t) with
  | Input { addresses } ->
    let p = Array.length addresses in
    (match In_channel.(input_line stdin) with
     | None -> End_of_input
     | Some st ->
       let input_length = String.length st in
       let expected_length = architecture * p in
       if input_length <> expected_length
       then
         Runtime_error
           (Error.create_s
              [%sexp
                "Unexpected input length."
              , { expected_length : int; input_length : int; input = (st : string) }])
       else (
         Array.iteri addresses ~f:(fun i address ->
           Bit_array.blit_init
             ~dst:(Interpreted_code.Memory.fetch memory ~address)
             ~f:(fun j -> Char.equal st.[(i * architecture) + j] '1'));
         Continue))
  | Output { addresses } ->
    Array.iter addresses ~f:(fun address ->
      print_string (Bit_array.to_string (Interpreted_code.Memory.fetch memory ~address)));
    Out_channel.newline stdout;
    Out_channel.flush stdout;
    Continue
  | Operation { operator; operands } ->
    let operands =
      Array.map operands ~f:(fun address -> Interpreted_code.Memory.fetch memory ~address)
    in
    (match Operator.compute operator ~operands with
     | Ok () -> Continue
     | Error error ->
       Runtime_error
         (Error.createf
            "Runtime error.\n%s"
            (Sexp.to_string_hum [%sexp { operator : Operator.t }, (error : Error.t)])))
;;

let execute_code ~interpreted_code:{ Interpreted_code.architecture; memory; code } =
  let exception End_of_execution of unit Or_error.t in
  try
    while true do
      Array.iter code ~f:(fun instruction ->
        match execute_instruction ~architecture ~memory ~instruction with
        | Continue -> ()
        | End_of_input -> Stdlib.raise_notrace (End_of_execution (Ok ()))
        | Runtime_error err -> Stdlib.raise_notrace (End_of_execution (Error err)))
    done;
    (assert false : unit Or_error.t)
  with
  | End_of_execution res -> res
;;

let run_program ~architecture ~program =
  let interpreted_code = Interpreted_code.of_program ~architecture ~program in
  execute_code ~interpreted_code
;;
