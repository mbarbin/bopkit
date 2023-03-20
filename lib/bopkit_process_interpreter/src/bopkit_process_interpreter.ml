open! Core
open! Or_error.Let_syntax

let execute_instruction
  ~(break : unit Or_error.t return)
  ~architecture
  ~memory
  ~instruction
  =
  match (instruction : Interpreted_code.Instruction.t) with
  | Input { addresses } ->
    let p = Array.length addresses in
    let st =
      match In_channel.(input_line stdin) with
      | Some line -> line
      | None -> break.return (return ())
    in
    let input_length = String.length st in
    let expected_length = architecture * p in
    if input_length <> expected_length
    then
      Or_error.errorf
        "Error: Unexpected input length.\n%s"
        (Sexp.to_string_hum
           [%sexp { expected_length : int; input_length : int; input = (st : string) }])
      |> break.return
    else
      Array.iteri addresses ~f:(fun i address ->
        Bit_array.blit_init
          ~dst:(Interpreted_code.Memory.fetch memory ~address)
          ~f:(fun j -> Char.equal st.[(i * architecture) + j] '1'))
  | Output { addresses } ->
    Array.iter addresses ~f:(fun address ->
      print_string (Bit_array.to_string (Interpreted_code.Memory.fetch memory ~address)));
    Out_channel.newline stdout;
    Out_channel.flush stdout
  | Operation { operator; operands } ->
    let operands =
      Array.map operands ~f:(fun address -> Interpreted_code.Memory.fetch memory ~address)
    in
    (match Operator.compute operator ~operands with
     | Ok () -> ()
     | Error error ->
       Or_error.errorf
         "Runtime error.\n%s"
         (Sexp.to_string_hum [%sexp { operator : Operator.t }, (error : Error.t)])
       |> break.return)
;;

let execute_code ~interpreted_code:{ Interpreted_code.architecture; memory; code } =
  with_return (fun break ->
    while true do
      Array.iter code ~f:(fun instruction ->
        execute_instruction ~break ~architecture ~memory ~instruction)
    done;
    return ())
;;

let run_program ~error_log ~architecture ~program =
  let%bind interpreted_code =
    Interpreted_code.of_program ~error_log ~architecture ~program
  in
  execute_code ~interpreted_code
;;
