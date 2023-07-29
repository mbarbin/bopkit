module Sites : sig
  (** stdlib/ contains *.bop files that can be included into other bop files
      using the following syntax:

      {[
        #include <file.bop>
      ]}

      These files are available to all bopkit projects, such as <stdlib.bop>,
      <bopboard.bop>, and possibly more.

      Packages external to bopkit can install additional files there to extend
      the stdlib. *)
  val stdlib : string list

  (** bopboard/ include files needed at runtime by the bopboard executable, such
      as images. *)
  val bopboard : string list

  (** stdbin/ include additional binaries needed by external blocks, expected to
      be installed as part of the distribution. It is added to the PATH by the
      bopkit simulator when running external blocs found in [*.bop] files. *)
  val stdbin : string list
end
