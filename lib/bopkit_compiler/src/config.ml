open! Core

type t =
  { optimize_cds : bool
  ; print_pass_output : Pass_name.t list
  ; parameters_overrides : Bopkit.Parameters.t
  ; main : string option
  }
[@@deriving fields]

let default =
  { optimize_cds = false; print_pass_output = []; parameters_overrides = []; main = None }
;;

let param =
  let%map_open.Command optimize_cds =
    flag
      "optimize-cds"
      (optional_with_default false bool)
      ~doc:"BOOL perform cds optimization (def: false)"
  and print_pass_output =
    flag
      "print-pass-output"
      (optional_with_default
         []
         (Arg_type.enumerated_sexpable (module Pass_name) |> Arg_type.comma_separated))
      ~doc:"PASS[,PASS]* supply pass names whose output to print"
  and parameters_overrides = Bopkit.Parameters.overrides
  and main =
    flag
      "main"
      (optional string)
      ~doc:"NAME override block name to simulate as the circuit entry point"
  in
  { optimize_cds; print_pass_output; parameters_overrides; main }
;;

let optimize_cds t = t.optimize_cds

let print_pass_output t ~pass_name =
  List.mem t.print_pass_output pass_name ~equal:Pass_name.equal
;;
