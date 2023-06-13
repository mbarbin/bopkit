open! Core

let colorPC = Graphics.green
and colorA = Graphics.yellow
and colorB = Graphics.magenta
and colorW = Graphics.red
and colorC = Graphics.cyan

class subleq_machine architecture init =
  object (this)
    val ram =
      Bopkit_memory.create
        ~name:"Subleq Debugger"
        ~address_width:architecture
        ~data_width:architecture
        ~kind:Ram
        ~init
        ()

    val length = Int.pow 2 architecture
    val mutable pc = 0
    method termination_condition = pc = 1
    method draw = Bopkit_memory.draw ram

    method run =
      prerr_endline "Subleq debugger: running...";
      while not this#termination_condition do
        this#iter
      done;
      prerr_endline "Reached termination condition (PC=1), end of the computation."

    method iter =
      Printf.fprintf stderr "PC != 1 -- we continue.\n";
      Bopkit_memory.reset_all_color ram;
      let pc1 = (pc + 1) % length
      and pc2 = (pc + 2) % length
      and pc3 = (pc + 3) % length in
      let a = Bopkit_memory.read_int ram ~address:(pc % length)
      and b = Bopkit_memory.read_int ram ~address:pc1
      and c = Bopkit_memory.read_int ram ~address:pc2 in
      let a' = Bopkit_memory.read_int ram ~address:(a % length)
      and b' = Bopkit_memory.read_int ram ~address:(b % length) in
      let diff = (b' - a') % length in
      Bopkit_memory.set_color ram ~address:pc ~color:colorPC;
      Printf.fprintf stderr "Read address [PC] value A = %d\n" a;
      Out_channel.flush stderr;
      Bopkit_memory.wait ram;
      Bopkit_memory.set_color ram ~address:a ~color:colorA;
      Printf.fprintf stderr "Read address [A] value = %d\n" a';
      Out_channel.flush stderr;
      Bopkit_memory.wait ram;
      Bopkit_memory.set_color ram ~address:pc1 ~color:colorPC;
      Printf.fprintf stderr "Read [PC+1] value B = %d\n" b;
      Out_channel.flush stderr;
      Bopkit_memory.wait ram;
      Bopkit_memory.set_color ram ~address:b ~color:colorB;
      Printf.fprintf stderr "Read address [B] value = %d\n" b';
      Out_channel.flush stderr;
      Bopkit_memory.wait ram;
      Bopkit_memory.write_int ram ~address:b ~value:diff;
      Bopkit_memory.set_color ram ~address:b ~color:colorW;
      Printf.fprintf
        stderr
        "Write into [B](%d) the result of [*B - *A] (%d - %d = %d)\n"
        b
        b'
        a'
        diff;
      Out_channel.flush stderr;
      Bopkit_memory.wait ram;
      let neg = not (diff > 0 && diff < length / 2) in
      if neg
      then (
        Bopkit_memory.set_color ram ~address:pc2 ~color:Graphics.green;
        Bopkit_memory.set_color ram ~address:c ~color:colorC;
        Printf.fprintf stderr "This result is negative or null.\n";
        Printf.fprintf stderr "=> We jump to value contained at [PC+2].\n")
      else (
        Bopkit_memory.set_color ram ~address:pc3 ~color:colorC;
        Printf.fprintf stderr "This result is strictly positive.\n";
        Printf.fprintf stderr "=> We jump to [PC+3].\n");
      Out_channel.flush stderr;
      Bopkit_memory.wait ram;
      Out_channel.flush stderr;
      pc <- (if neg then c else pc3) % length
  end

type t = { subleq : subleq_machine }

let create_exn (init : Bit_matrix.t) =
  let dimx = Array.length init in
  let dimy = if dimx = 0 then 0 else Array.length init.(0) in
  if dimx <> Int.pow 2 dimy
  then raise_s [%sexp "Invalid subleq memory dimensions", [%here]];
  let subleq = new subleq_machine dimy init in
  Graphics.open_graph " 300x400";
  Graphics.set_window_title "Subleq Debugger";
  { subleq }
;;

let run (t : t) =
  try t.subleq#run with
  | Bopkit_memory.Escape_key_pressed | Graphics.Graphic_failure _ -> ()
;;
