open! Core

(* The controller part of the subleq demo we built is responsible for making the
   connection between the internal subleq machine, and the disk_interface
   device which has the ability to do read/write on disk (the subleq machine
   cannot).

   At high-level, the controller makes sure that for each new RAM input file:

   1. The file contents is first loaded into the subleq memory.
   2. Then the subleq is instructed to run and compute the resulting program
      image.
   3. After the image is computed, the controller copies the contents of the
      subleq memory back into the disk_interface, and instruct the latter to
      save it to disk, before loading the next program.

   The controller is here implemented in OCaml but conceptually it could very
   well be a bopkit circuit. At the time we wrote this project (2008), we didn't
   have bopkit mode-automata yet, and this controller is very much a state
   machine.

   Perhaps we'll migrate this file to a bopkit automata as a follow-up project
   at some point! In the meantime, we wrote it in a style that is fairly close
   to that of a circuit, so it should'nt be too far from its potential bopkit
   equivalent. *)

module State = struct
  (* The lifecycle of the state is as follows:

  {v
       STANDBY
    -> INIT
    -> Foreach i, LOADING i
    -> WAITING
    -> Foreach i, SAVING i
    -> STANDBY
  v}

  The details meaning for the states are:

   STANDBY: doing nothing, waiting for a RESET
   INIT: temporary state before staring the LOADING process
   LOADING i: transferring memory from disk_interface --> subleq. At index [i].
   WAITING: waiting for the subleq to finish its computation
   SAVING i: transferring memory back from subleq --> disk_interface. At index [i]
   STANDBY: back to the initial state, ready to start for the next program
*)

  type t =
    | INIT
    | LOADING of int
    | WAITING
    | SAVING of int
    | STANDBY
  [@@deriving equal]
end

let main ar =
  let current_state = ref (INIT : State.t) in
  let termination_condition = ref false in
  let old_reset = ref true in
  let real_reset = ref false in
  let length = Int.pow 2 ar in
  let sl_run = ref false in
  let sl_set_pc = ref false in
  let sl_pc_in = Array.create ~len:ar false in
  let sl_write = ref false in
  let sl_address = Array.create ~len:ar false in
  let sl_data_in = Array.create ~len:ar false in
  let cr_address = Array.create ~len:ar false in
  let cr_write = ref false in
  let cr_data_in = Array.create ~len:ar false in
  let cr_standby = ref false in
  let blit_output ~output =
    let index = ref 0 in
    let blit_ref r =
      output.(!index) <- !r;
      incr index
    in
    let blit_arr t =
      Array.blit ~src:t ~src_pos:0 ~dst:output ~dst_pos:!index ~len:ar;
      index := !index + ar
    in
    blit_ref sl_run;
    blit_ref sl_set_pc;
    blit_arr sl_pc_in;
    blit_ref sl_write;
    blit_arr sl_address;
    blit_arr sl_data_in;
    blit_arr cr_address;
    blit_ref cr_write;
    blit_arr cr_data_in;
    blit_ref cr_standby
  in
  Bopkit_block.Method.main
    ~input_arity:
      (Tuple_4 (Signal, Bus { width = ar }, Bus { width = ar }, Bus { width = ar }))
    ~output_arity:(Bus { width = 1 + 1 + ar + 1 + ar + ar + ar + 1 + ar + 1 })
    ~f:(fun ~input:(reset, sl_pc_out, sl_data_out, cr_data_out) ~output ->
      (* real_reset = Posedge(reset) *)
      real_reset := reset && not !old_reset;
      old_reset := reset;
      cr_standby := State.equal !current_state STANDBY;
      Array.blit ~src:sl_data_out ~src_pos:0 ~dst:cr_data_in ~dst_pos:0 ~len:ar;
      Array.blit ~src:cr_data_out ~src_pos:0 ~dst:sl_data_in ~dst_pos:0 ~len:ar;
      termination_condition := Bit_array.to_int sl_pc_out = 1;
      (match !current_state with
       | INIT ->
         sl_run := false;
         sl_set_pc := false;
         sl_write := false;
         Bit_array.blit_int ~src:0 ~dst:cr_address;
         cr_write := false;
         current_state := LOADING 0
       | LOADING k when k < pred length ->
         sl_run := false;
         sl_set_pc := false;
         sl_write := true;
         Bit_array.blit_int ~src:k ~dst:sl_address;
         cr_write := false;
         Bit_array.blit_int ~src:(succ k) ~dst:cr_address;
         current_state := LOADING (succ k)
       | LOADING k ->
         sl_run := false;
         sl_set_pc := true;
         Bit_array.blit_int ~src:0 ~dst:sl_pc_in;
         sl_write := true;
         Bit_array.blit_int ~src:k ~dst:sl_address;
         cr_write := false;
         current_state := WAITING
       | WAITING ->
         if !termination_condition
         then (
           sl_run := false;
           sl_set_pc := false;
           sl_write := false;
           Bit_array.blit_int ~src:0 ~dst:sl_address;
           cr_write := false;
           current_state := SAVING 0)
         else (
           sl_run := true;
           cr_write := false)
       | SAVING k when k < pred length ->
         sl_run := false;
         sl_set_pc := false;
         sl_write := false;
         cr_write := true;
         Bit_array.blit_int ~src:k ~dst:cr_address;
         Bit_array.blit_int ~src:(succ k) ~dst:sl_address;
         current_state := SAVING (succ k)
       | SAVING k ->
         sl_run := false;
         sl_set_pc := false;
         sl_write := false;
         cr_write := true;
         Bit_array.blit_int ~src:k ~dst:cr_address;
         current_state := STANDBY
       | STANDBY ->
         sl_run := false;
         sl_set_pc := false;
         sl_write := false;
         Bit_array.blit_int ~src:0 ~dst:cr_address;
         cr_write := false;
         if !real_reset then current_state := INIT);
      blit_output ~output)
;;

let () =
  Bopkit_block.run
    (let open Command.Let_syntax in
     let%map_open ar = flag "AR" (required int) ~doc:" architecture" in
     Bopkit_block.create ~name:"controller" ~main:(main ar) ())
;;
