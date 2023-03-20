open! Core

include
  String_id.Make
    (struct
      let module_name = "Process.Ident"
    end)
    ()
