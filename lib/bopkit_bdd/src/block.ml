open! Core
open! Import

type t =
  { input_size : int
  ; output_size : int
  ; body : Muxlist.t
  }
[@@deriving sexp_of]

let rec muxtree_uses_et t =
  match (t : Muxtree.t) with
  | Constant None -> true
  | Constant (Some (_ : bool)) | Signal (_ : Ident.t) | Not_signal (_ : Ident.t) -> false
  | Mux { input = (_ : int); vdd; gnd } -> muxtree_uses_et vdd || muxtree_uses_et gnd
;;

let uses_et t =
  List.exists t.body ~f:(fun { output = _; muxtree } -> muxtree_uses_et muxtree)
;;

let used_inputs (t : t) =
  let used_inputs = Hash_set.create (module Int) in
  let use_input i = Hash_set.add used_inputs i in
  let rec aux (t : Muxtree.t) =
    match (t : Muxtree.t) with
    | Constant (_ : bool option) -> ()
    | Signal i | Not_signal i ->
      (match i with
       | Input i -> use_input i
       | Output _ | Internal _ -> ())
    | Mux { input = i; vdd; gnd } ->
      use_input i;
      aux vdd;
      aux gnd
  in
  List.iter t.body ~f:(fun { output = _; muxtree } -> aux muxtree);
  used_inputs
;;

module Name = struct
  let unspecified_bit_block = "Star"
  let input = "a"
  let output = "out"
  let internal = "s"
end

let unused_variables t =
  let used_inputs = used_inputs t in
  t.input_size
  |> List.init ~f:(fun i -> Option.some_if (not (Hash_set.mem used_inputs i)) i)
  |> List.filter_opt
  |> List.group ~break:(fun i j -> i + 1 < j)
  |> List.map ~f:(fun interval ->
       let index =
         match interval with
         | [] -> assert false
         | [ i ] -> Bopkit.Netlist.Index (CST i)
         | first :: (_ :: _ as tl) ->
           let last = List.last_exn tl in
           Bopkit.Netlist.Interval (CST first, CST last)
       in
       Bopkit.Netlist.Bus { loc = Loc.dummy_pos; name = Name.input; indexes = [ index ] })
;;

let pp_ident ident =
  match (ident : Ident.t) with
  | Input i -> Pp.textf "%s[%d]" Name.input i
  | Output i -> Pp.textf "%s[%d]" Name.output i
  | Internal i -> Pp.textf "%s%d" Name.internal i
;;

let rec pp_muxtree muxtree =
  let open Pp.O in
  match (muxtree : Muxtree.t) with
  | Constant (Some value) -> Pp.char (if value then '1' else '0')
  | Constant None -> Pp.textf "%s()" Name.unspecified_bit_block
  | Signal i -> pp_ident i
  | Not_signal i -> Pp.verbatim "Not(" ++ pp_ident i ++ Pp.verbatim ")"
  | Mux { input; vdd; gnd } ->
    Pp.concat
      [ Pp.verbatim "Mux("
      ; pp_ident (Ident.Input input)
      ; Pp.verbatim "," ++ Pp.space
      ; pp_muxtree vdd
      ; Pp.verbatim "," ++ Pp.space
      ; pp_muxtree gnd
      ; Pp.verbatim ")"
      ]
    |> Pp.hvbox ~indent:2
;;

let et =
  lazy
    (sprintf {|
%s () = s
where
  s = Vdd();
end where;
|} Name.unspecified_bit_block
     |> String.strip)
;;

let pp_t (t : t) =
  let open Pp.O in
  let unused_variables = unused_variables t in
  Pp.concat
    [ (if uses_et t then Pp.verbatim (force et) ++ Pp.newline ++ Pp.newline else Pp.nop)
    ; Pp.textf "Bloc(%s:[%d])" Name.input t.input_size
    ; Pp.verbatim " = "
    ; Pp.textf "%s:[%d]" Name.output t.output_size
    ; Pp.newline
    ; (match unused_variables with
       | [] -> Pp.nop
       | [ var ] ->
         Pp.concat
           [ Pp.verbatim "with unused = "; Bopkit_pp.Netlist.pp_variable var; Pp.newline ]
       | _ :: _ :: _ ->
         Pp.concat
           [ Pp.verbatim "with unused = ("
           ; Pp.concat_map
               unused_variables
               ~sep:(Pp.verbatim ", ")
               ~f:Bopkit_pp.Netlist.pp_variable
           ; Pp.verbatim ")"
           ; Pp.newline
           ])
    ; Pp.verbatim "where"
      ++ Pp.newline
      ++ Pp.concat
           ~sep:Pp.newline
           (List.map t.body ~f:(fun { output; muxtree } ->
              Pp.concat
                [ pp_ident output
                ; Pp.verbatim " ="
                ; Pp.space
                ; pp_muxtree muxtree
                ; Pp.char ';'
                ]
              |> Pp.box ~indent:2))
      |> Pp.box ~indent:2
    ; Pp.newline
    ; Pp.verbatim "end where;"
    ; Pp.newline
    ]
;;

let pp fmt t = Pp.to_fmt fmt (pp_t t)

let of_muxtrees muxtrees ~input_size =
  { input_size
  ; output_size = List.length muxtrees
  ; body =
      List.mapi muxtrees ~f:(fun i muxtree -> { Muxlist.Node.output = Output i; muxtree })
  }
;;

let of_muxlist muxlist ~input_size =
  let output_size =
    let max = ref 0 in
    List.iter muxlist ~f:(fun { Muxlist.Node.output; muxtree = _ } ->
      match output with
      | Input _ | Internal _ -> ()
      | Output i -> max := Int.max !max (i + 1));
    !max
  in
  { input_size; output_size; body = muxlist }
;;

let number_of_gates t =
  List.sum
    (module Int)
    t.body
    ~f:(fun { output = _; muxtree } -> Muxtree.number_of_gates muxtree)
;;
