Checking behavior of an empty circuit. In particular, this should correctly read
empty lines from stdin, and write empty lines to stdout.

  $ ./empty.exe

  $ ./empty.exe <<EOF
  > 
  > 
  > 
  
  
  

  $ ./empty.exe <<EOF
  > 1
  Input line too long.
  Expected 0 bits followed by '\n'.
  [1]
