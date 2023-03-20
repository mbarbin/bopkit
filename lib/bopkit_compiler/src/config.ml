open! Core

type t =
  { optimise_cds : bool
  ; print_pass_output : Pass_name.t list
  }

let default = { optimise_cds = false; print_pass_output = [] }

let param =
  let%map_open.Command optimise_cds =
    flag
      "optimise-cds"
      (optional_with_default false bool)
      ~doc:"BOOL perform cds optimisation (def: false)"
  and print_pass_output =
    flag
      "print-pass-output"
      (optional_with_default
         []
         (Arg_type.enumerated_sexpable (module Pass_name) |> Arg_type.comma_separated))
      ~doc:"PASS[,PASS]* supply pass names whose output to print"
  in
  { optimise_cds; print_pass_output }
;;

let optimise_cds t = t.optimise_cds

let print_pass_output t ~pass_name =
  List.mem t.print_pass_output pass_name ~equal:Pass_name.equal
;;
