module Macro_frame = struct
  include Visa_simulator.Execution_stack.Macro_frame

  let render_lines_for_debugging t =
    let int_len =
      Array.length t.assembly_instructions |> Int.to_string |> String.length
    in
    let index i = sprintf "%0*d" int_len i in
    [ [ sprintf "/ %s" (t.macro_name.symbol |> Visa.Macro_name.to_string)
      ; sprintf
          "| %s"
          (t.bindings
           |> List.map ~f:(fun (parameter_name, (argument : _ With_loc.t)) ->
             sprintf
               "%s=>%s"
               (Visa.Parameter_name.to_string parameter_name)
               (Visa.Assembly_instruction.Argument.to_string argument.symbol))
           |> String.concat ~sep:", ")
      ; "|"
      ; sprintf "| macro_code_pointer = %s" (index t.macro_code_pointer)
      ; "|"
      ]
    ; Array.mapi t.assembly_instructions ~f:(fun i assembly_instruction ->
        sprintf
          "| %s: %s"
          (index i)
          (Visa.Assembly_instruction.to_string assembly_instruction))
      |> Array.to_list
    ; [ sprintf "\\" ]
    ]
    |> List.concat
  ;;
end

include (
  Visa_simulator.Execution_stack :
    module type of Visa_simulator.Execution_stack with module Macro_frame := Macro_frame)

let render_lines_for_debugging t =
  List.concat_map (Stack.to_list t.macro_frames) ~f:Macro_frame.render_lines_for_debugging
;;
