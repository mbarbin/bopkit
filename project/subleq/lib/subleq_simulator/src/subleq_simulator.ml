(* To detect cycles in the Subleq execution, we use the algorithm known as the
   "rho of pollard", or "Floyd algorithm". See for example:
   http://fr.wikipedia.org/wiki/Algorithme_du_lièvre_et_de_la_tortue
*)

class subleq ~architecture =
  object (this)
    (* We use 2 RAMs to detect cycles with Floyd's algorithm. *)
    (* We keep the initial state in order to compute the ratio of changes. *)
    val init = Array.make_matrix ~dimx:(Int.pow 2 architecture) ~dimy:architecture false
    val ram = Array.create ~len:(Int.pow 2 architecture) 0
    val mutable pc = 0
    val length = Int.pow 2 architecture
    val ram2 = Array.create ~len:(Int.pow 2 architecture) 0
    val mutable pc_ram2 = 0
    val mutable cycle = false

    (* The index is also called PC for program counter. *)
    val mutable index = 0

    (* Testing the equality of the 2 rams. The test should take PC into account. *)
    method equal =
      if pc <> pc_ram2
      then false
      else (
        let rec aux i =
          if i >= length
          then true
          else if Array.unsafe_get ram i <> Array.unsafe_get ram2 i
          then false
          else aux (succ i)
        in
        aux 0)

    method ratio_change =
      let ch = ref 0
      and bits = Array.create ~len:architecture false in
      for i = 0 to pred length do
        Bit_array.blit_int ~dst:bits ~src:ram.(i);
        for j = 0 to pred architecture do
          if Bool.( <> ) init.(i).(j) bits.(j) then incr ch
        done
      done;
      float_of_int (100 * !ch) /. float_of_int (length * architecture)

    method load value =
      let len_value = Array.length value in
      if len_value <> length || Array.length value.(0) <> architecture
      then raise_s [%sexp "Invalid memory dimensions", [%here]];
      pc <- 0;
      pc_ram2 <- 0;
      index <- 0;
      cycle <- false;
      for i = 0 to pred length do
        for j = 0 to pred architecture do
          init.(i).(j) <- value.(i).(j)
        done;
        let r = Bit_array.to_int value.(i) in
        ram.(i) <- r;
        ram2.(i) <- r
      done

    method print_ram_text st =
      let bm = Array.make_matrix ~dimx:length ~dimy:architecture false in
      for i = 0 to pred length do
        Bit_array.blit_int ~dst:bm.(i) ~src:ram.(i)
      done;
      Bit_matrix.to_text_channel bm st

    method termination_condition = pc = 1

    method stop cycle =
      if cycle
      then prerr_endline "[ ;-( ] Cycle detected : Aborting computation."
      else (
        let ratio = this#ratio_change in
        Printf.fprintf
          stderr
          "[ ;-) ] Program terminated after %d steps. IM %2.2f %c diff.\n"
          index
          ratio
          '%';
        Out_channel.flush stderr)

    method run =
      prerr_endline "Subleq simulator: running...";
      while (not this#termination_condition) && not cycle do
        this#iter;
        let cmp = this#equal in
        if cmp then cycle <- true else ()
      done;
      if cycle
      then (
        (* We check whether the termination condition is met between m and 2m. *)
        let stop = 2 * index in
        while (not this#termination_condition) && index <= stop do
          this#iter_one_only
        done;
        if index > stop
        then (
          this#stop true;
          true)
        else (
          this#stop false;
          false))
      else (
        this#stop false;
        false)

    (* Once we detected that fm(r) = f2m(r), we iter from 2 to 2m to check
       whether the termination condition is met in between. If so, the program
       doesn't loop. *)
    method iter_one_only =
      index <- succ index;
      (* 1 iteration on ram 1 *)
      let pc1 = (pc + 1) mod length
      and pc2 = (pc + 2) mod length in
      let b = ram.(pc1) in
      let a' = ram.(ram.(pc))
      and b' = ram.(b) in
      let diff = (b' - a' + length) mod length in
      ram.(b) <- diff;
      if diff <= 0 || diff >= length / 2
      then pc <- ram.(pc2)
      else pc <- (pc + 3) mod length

    method iter =
      index <- succ index;
      (* 1 iteration on ram 1 *)
      let pc1 = (pc + 1) mod length
      and pc2 = (pc + 2) mod length in
      let b = ram.(pc1) in
      let a' = ram.(ram.(pc))
      and b' = ram.(b) in
      let diff = (b' - a' + length) mod length in
      ram.(b) <- diff;
      if diff <= 0 || diff >= length / 2
      then pc <- ram.(pc2)
      else pc <- (pc + 3) mod length;
      (* 2 iterations on ram 2 *)
      for _ = 0 to 1 do
        let pc1 = (pc_ram2 + 1) mod length
        and pc2 = (pc_ram2 + 2) mod length in
        let b = ram2.(pc1) in
        let a' = ram2.(ram2.(pc_ram2))
        and b' = ram2.(b) in
        let diff = (b' - a' + length) mod length in
        ram2.(b) <- diff;
        if diff <= 0 || diff >= length / 2
        then pc_ram2 <- ram2.(pc2)
        else pc_ram2 <- (pc_ram2 + 3) mod length
      done
  end

type t = { subleq : subleq }

let create ~architecture =
  let subleq = new subleq ~architecture in
  { subleq }
;;

let reset_exn (t : t) initial_memory = t.subleq#load initial_memory

module Run_result = struct
  type t =
    | Success
    | Program_does_not_terminate
  [@@deriving equal, sexp_of]
end

let run (t : t) : Run_result.t =
  match t.subleq#run with
  | true -> Program_does_not_terminate
  | false -> Success
;;

let print_memory (t : t) ~out_channel = t.subleq#print_ram_text out_channel
