type t = Comment.t list Comments_parser.Comment_node.t [@@deriving equal, sexp_of]

let value t = Comments_parser.Comment_node.value_exn t
let is_empty t = List.is_empty (value t)

let make ~attached_to =
  Comments_parser.comment_node ~attached_to ~f:(fun comments ->
    List.map comments ~f:Comment.parse_exn)
;;

let none = Comments_parser.Comment_node.return []
