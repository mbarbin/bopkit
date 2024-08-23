(** Create the standalone netlist from all of the project's files, simply by
    concatenating them all. Topological ordering is done separately later. *)

val pass : path:Fpath.t -> Standalone_netlist.t
