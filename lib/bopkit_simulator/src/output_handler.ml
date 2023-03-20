open! Core

type t =
  { output_kind : Config.Output_kind.t
  ; last_output : Bit_array.t
  ; mutable index_cycle : int
  ; input_names : string array
  ; output_names : string array
  }

let create ~config ~input_names ~output_names =
  { output_kind = Config.output_kind config
  ; last_output = Array.map output_names ~f:(const false)
  ; index_cycle = -1
  ; input_names
  ; output_names
  }
;;

let print_output ~output ~print_if_empty =
  if Array.length output > 0 || print_if_empty
  then (
    Printf.printf "%s\n" (Bit_array.to_string output);
    Out_channel.flush stdout)
;;

let output_changed t ~output =
  let result = t.index_cycle = 0 || not (Bit_array.equal t.last_output output) in
  Array.blit
    ~src:output
    ~src_pos:0
    ~dst:t.last_output
    ~dst_pos:0
    ~len:(Array.length output);
  result
;;

let char_of_bool = Bit_string_encoding.Bit.to_char

let output t ~input ~output =
  t.index_cycle <- succ t.index_cycle;
  match t.output_kind with
  | Default { output_only_on_change } ->
    if (not output_only_on_change) || output_changed t ~output
    then print_output ~output ~print_if_empty:false
  | As_external_block -> print_output ~output ~print_if_empty:true
  | Show_input ->
    if not (Array.is_empty input && Array.is_empty output)
    then (
      Printf.printf "%8d |" t.index_cycle;
      Array.iter input ~f:(fun i -> Printf.printf " %c" (char_of_bool i));
      Printf.printf " |";
      Array.iter output ~f:(fun i -> Printf.printf " %c" (char_of_bool i));
      Printf.printf "\n";
      Out_channel.flush stdout)
;;

let init t =
  match t.output_kind with
  | Default { output_only_on_change = _ } | As_external_block -> ()
  | Show_input ->
    if not (Array.is_empty t.input_names && Array.is_empty t.output_names)
    then (
      Printf.printf "%8s |" "Cycle";
      Array.iter t.input_names ~f:(fun name -> Printf.printf " %s" name);
      Printf.printf " |";
      Array.iter t.output_names ~f:(fun name -> Printf.printf " %s" name);
      Printf.printf "\n";
      Out_channel.flush stdout)
;;
