(*********************************************************************************)
(*  bopkit: An educational project for digital circuits programming              *)
(*  SPDX-FileCopyrightText: 2007-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module With_labels = struct
  type t = Visa.Executable.With_labels.t

  let pp (t : t) =
    let open Pp.O in
    let sections =
      let sections = Queue.create () in
      let section = Queue.create () in
      let close_section () =
        if not (Queue.is_empty section)
        then (
          Queue.enqueue sections (Queue.to_list section);
          Queue.clear section)
      in
      Array.iter t ~f:(fun ie ->
        if Option.is_some ie.label_introduction then close_section ();
        Queue.enqueue section ie);
      close_section ();
      Queue.to_list sections
    in
    List.map sections ~f:(fun instructions ->
      match instructions with
      | [] -> Pp.nop
      | hd :: _ ->
        let instructions =
          List.map instructions ~f:(fun ie ->
            Visa.Instruction.to_string ie.instruction ~label:Fn.id |> Pp.verbatim)
          |> Pp.concat ~sep:Pp.newline
        in
        (match hd.label_introduction with
         | None -> instructions
         | Some label ->
           Pp.verbatim (Visa.Label.to_string label)
           ++ Pp.verbatim ":"
           ++ Pp.newline
           ++ instructions
           |> Pp.box ~indent:2)
        ++ Pp.newline)
    |> Pp.concat
  ;;
end

type t = Visa.Executable.t

let pp (t : t) =
  let open Pp.O in
  let int_len = Array.length t |> Int.to_string |> String.length in
  let label i = sprintf "%0*d" int_len i |> Visa.Label.of_string in
  Array.mapi t ~f:(fun i instruction ->
    Pp.verbatim (label i |> Visa.Label.to_string)
    ++ Pp.verbatim ": "
    ++ Pp.verbatim
         (Visa.Instruction.to_string instruction ~label:(fun i ->
            label (Visa.Executable.Instruction_pointer.to_int i)))
    ++ Pp.newline)
  |> Array.to_list
  |> Pp.concat
;;

module Machine_code = struct
  type t = Visa.Executable.Machine_code.t

  let pp (t : t) =
    let open Pp.O in
    Array.map
      (t : t)
      ~f:(fun i -> Pp.verbatim (Visa.Machine_code.Byte.to_string i) ++ Pp.newline)
    |> Array.to_list
    |> Pp.concat
  ;;
end
