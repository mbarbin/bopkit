include Visa_simulator.Code

let render_lines_for_debugging t =
  let int_len = Array.length t.statements |> Int.to_string |> String.length in
  let index i = sprintf "%0*d" int_len i in
  Array.mapi t.statements ~f:(fun i { labels; assembly_instruction } ->
    let labels =
      if List.is_empty labels
      then ""
      else (
        let labels =
          List.map labels ~f:(fun t -> Visa.Label.to_string t.symbol)
          |> String.concat ~sep:","
        in
        sprintf "%s: " labels)
    in
    sprintf
      "%s| %s%s"
      (index i)
      labels
      (assembly_instruction |> Visa.Assembly_instruction.to_string))
  |> Array.to_list
;;
