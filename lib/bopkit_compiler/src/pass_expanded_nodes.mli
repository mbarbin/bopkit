open! Core

val pass
  :  env:Expanded_block.env
  -> main_block_name:string
  -> error_log:Error_log.t
  -> Expanded_nodes.t
