type t = Comment.t list Parsing_utils.Comments_state.Comment_node.t
[@@deriving equal, sexp_of]

let value t = Parsing_utils.Comments_state.Comment_node.value_exn t
let is_empty t = List.is_empty (value t)

let make ~attached_to =
  Parsing_utils.Comments_state.comment_node ~attached_to ~f:(fun comments ->
    List.map comments ~f:Comment.parse_exn)
;;

let none = Parsing_utils.Comments_state.Comment_node.return []
