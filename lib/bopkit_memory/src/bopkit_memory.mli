(** In bopkit circuits you can define and use memory units, which can be of type
    RAM or ROM. This module allows to display the contents of a memory in an
    OCaml Graphics window.

    This can be nice for building demos, debug applications, etc. The window
    allows for some interaction with the user through Graphics events (mouse and
    keyboard). For example, you can dynamically edit the contents of memory
    cells while a bopkit simulation is running. You can also display the values
    in memory using different formats, such as binary, signed, decimal, etc.

    At this time, this module only allows the display of a single memory per
    process (this is inherited from the constraint that you can only have a
    single OCaml Graphics window per process). In practice, this does not this
    constrain a simulation to have only a single memory, because we make use of
    module not in the main running simulation process, but rather in external
    processes, of which there can be multiple running at the same time.

    This module is not meant to be used directly by the bopkit user, rather this
    furnishes common ground utils to implement external blocks, which can in turn
    face the bopkit user.

    How does the memory look like ? It's simple, it's just tabular data in a
    graph:

    {v
      address: value  address:value  address: value  address:value
      address: value  address:value  address: value  address:value
      address: value  address:value  address: value  address:value
      ...
    v}

    When the entire memory does not fit on the window, scrolling is possible
    with [center_view], and in the main user event loop, by pressing the
    navigating keys '>' (next page) and '<' (previous page). *)

(** The type of a memory, with which you can read/write values and drive the
    graphic window. The parameter is used to distinguish between RAM and ROM
    memories. Most operations are available regardless of the type of memory,
    but some specific ones will constrain the type parameter. For example,
    writing to a memory cell from this interface is only allowed on RAM
    memories. *)
type 'a t

type ram
type rom

module Ram : sig
  type nonrec t = ram t
end

module Rom : sig
  type nonrec t = rom t
end

module Kind : sig
  type 'a t =
    | Ram : ram t
    | Rom : rom t
end

(** Creating a new memory of a given kind. The addresses and words width are
    constant for a given memory. When provided, [init] should have dimensions
    at least as big as the memory to be created, that is it should verify
    [dimx >= Int.pow 2 address_width] and [dimy >= data_width]. The name is
    only indicative and used during the display. *)
val create
  :  name:string
  -> address_width:int
  -> data_width:int
  -> kind:'a Kind.t
  -> ?init:Bit_matrix.t
  -> unit
  -> 'a t

(** Draw the current state of the memory on the OCaml Graphics window. Note a
    design choice made here: this module does not take care of opening the
    graph (it does not call [Graphics.open_graph]). This is left for the caller
    of this module to do.

    At the moment, refreshing the graphics is done in the main event loop, but
    is not done when the memory is modified programmatically through this
    interface. *)
val draw : _ t -> unit

(** Mutate the view pointer to center it on a given address. This doesn't modify
    the view, but will modify how the next [draw] will be done. This has no
    effect when it so happen that all the memory cell of the memory fit on the
    current graphics window. On the other hand, this may be useful for larger
    memory that requires scrolling through several pages. *)
val center_view
  :  _ t
  -> on_address:int
  -> [ `Done_now_needs_to_redraw | `Not_needed_did_nothing ]

(** When waiting for a user event, if the Escape key is pressed, this exception
    will be raised. *)
exception Escape_key_pressed

(** Enter an event loop that allows for some interaction, such as modifying the
    view or changing some memory cell. This function terminates when the user
    does a certain action, such as pressing space or return key. This is used
    by applications that implement step by step debugging with a graphical
    view. May raise [Escape_key_pressed]. *)
val wait : _ t -> unit

(** In the even loop, the user can enter a pause-mode, which may allow for
    example a simulation to stop. This can be accessed by another thread. *)
val pause_mode : _ t -> bool

(** Run the event loop and interact with the user. This should be run in a
    dedicated thread if the program needs to handle other things. If
    [read_only] is set to [true], the functionality that allows memory cell
    editing will be turned off. The event_loop is interupted and this function
    returns unit if it catches the exceptions [Escape_key_pressed] or
    [Graphic_failure _]. *)
val event_loop : _ t -> read_only:bool -> unit

(** {1 Color map}

    Memory cells in the window can be colored to highlight some parts. For
    example, some bopkit demo show in [red] memory cells that were just written
    to, and in [green] memory cells that were just read.

    This is done thanks to a color map that can be accessed and mutated through
    this api. Note that mutating the color map does not cause a redraw, but
    rather updates the map internally, and the color changes will be reflected on
    the next [draw]. *)

(** Update the color map, to be used by the next time [draw] is called. *)
val reset_all_color : _ t -> unit

(** Update the color map for a given address only. *)
val reset_color : _ t -> address:int -> unit

(** Tells if there exists a color override in the color map for this address. *)
val get_color : _ t -> address:int -> Graphics.color option

(** Add an override to the color map. The override will persist until
    [reset_color] or [reset_all_color] is called, or if the user click on the
    cell. *)
val set_color : _ t -> address:int -> color:Graphics.color -> unit

(** [set_color_option t ~address ~color_option] is just a convenient wrapper
    that either calls [set_color t ~address ~color] when [color_option=Some
    color] or [reset_color t ~address] when [color_option=None]. *)
val set_color_option : _ t -> address:int -> color:Graphics.color option -> unit

(** {1 Word printing style}

    The style of the display for the memory cells may be changed
    programmatically here using [set_word_print_style], or by pressing the keys
    1-2-3 in the user interface, to cycle through them. *)

module Word_printing_style : sig
  type t =
    | Decimal
    | SignedDecimal
    | Binary
  [@@deriving equal, sexp_of]
end

val set_word_printing_style : _ t -> word_printing_style:Word_printing_style.t -> unit

(** {1 File I/O} *)

(** Change the contents of the memory by taking boolean value from a memory file
    at the format text (containing chars '0' and '1'). For more details on
    memory files, see {!val:Bit_matrix.of_text_file} which is the function used
    under the hood here. *)
val load_text_file : _ t -> filename:string -> unit

(** Save the current contents of the memory to a text file, using
    {!Bit_matrix.to_text_file}. *)
val to_text_file : _ t -> filename:string -> unit

(** {1 Reading/Writing to the memory} *)

(** Read and return the word at the address in decimal. *)
val read_int : _ t -> address:int -> int

(** Read the word at the address and blit it to [dst]. The address can be
    shorter than the number of bits of the memory, but the [dst] must have the
    exact same width as the memory cells. *)
val read_bits : _ t -> address:bool array -> dst:Bit_array.t -> unit

(** Write to the supplied address the given decimal value. The binary value set
    will be done modulo the size of words, so this operation is defined even
    for negative or overflowing values. *)
val write_int : ram t -> address:int -> value:int -> unit

(** Write the word at the supplied address. [address] can be shorter than the
    memory address width, but [value] must have the exact same width as the
    memory cells. *)
val write_bits : ram t -> address:bool array -> value:Bit_array.t -> unit
