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

let arg =
  let%map_open.Command optimize_cds =
    Arg.named_with_default
      [ "optimize-cds" ]
      Param.bool
      ~default:false
      ~doc:"Specify whether to perform cds optimizations."
  and print_pass_output =
    Arg.named_with_default
      [ "print-pass-output" ]
      (Param.enumerated (module Pass_name) |> Param.comma_separated)
      ~default:[]
      ~docv:"PASS"
      ~doc:"Supply pass names whose output to print."
  and parameters_overrides = Bopkit.Parameters.overrides
  and main =
    Arg.named_opt
      [ "main" ]
      Param.string
      ~docv:"NAME"
      ~doc:"Override block name to simulate as the circuit entry point."
  in
  { optimize_cds; print_pass_output; parameters_overrides; main }
;;

let optimize_cds t = t.optimize_cds

let print_pass_output t ~pass_name =
  List.mem t.print_pass_output pass_name ~equal:Pass_name.equal
;;
