type t =
  { counter_input : Bit_counter.t option
  ; expected_input_length : int
  ; as_external_block : bool
  }

let create ~config ~expected_input_length =
  { counter_input =
      (if Config.counter_input config
       then Some (Bit_counter.create ~len:expected_input_length)
       else None)
  ; expected_input_length
  ; as_external_block =
      (match Config.output_kind config with
       | As_external_block -> true
       | Default _ | Show_input -> false)
  }
;;

let read_and_blit_input t ~dst =
  if t.expected_input_length > 0 || t.as_external_block
  then (
    let dst_len = Array.length dst in
    let input =
      match In_channel.input_line In_channel.stdin with
      | Some line -> line
      | None -> raise End_of_file
    in
    let input_len = String.length input in
    if input_len <> dst_len
    then
      Err.raise
        [ Pp.text "Unexpected stdin input length."
        ; Pp.textf
            "Input was %S - length %d - expected %d char(s)."
            input
            input_len
            dst_len
        ]
    else
      for i = 0 to Int.pred dst_len do
        let value =
          match input.[i] with
          | '0' -> false
          | '1' -> true
          | c ->
            Err.raise
              [ Pp.text "Unexpected input character."
              ; Pp.textf
                  "Input was %S - At pos %d, char %c: expected char '0' or '1'."
                  input
                  i
                  c
              ]
        in
        Array.unsafe_set dst i value
      done)
;;

let blit_input t ~dst =
  match t.counter_input with
  | None -> read_and_blit_input t ~dst
  | Some bit_counter -> Bit_counter.blit_next_value bit_counter ~dst ~dst_pos:0
;;
