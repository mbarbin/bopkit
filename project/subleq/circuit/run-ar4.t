Hello

  $ ls -1 test/*.img
  ls: cannot access 'test/*.img': No such file or directory
  [2]

  $ bopkit simu main.bop \
  >   --parameter 'DEBUG=0' \
  >   --parameter 'AR=4' \
  >   --parameter 'NumberOfPrograms=30' \
  >   --parameter 'FilesPrefix=test/ar4-' \
  >  2> trace.stderr

  $ tail -n 20 trace.stderr
  [ <-- ] Loading RAM <-- "test/ar4-27.input"
  Load memory "mem" from "test/ar4-27.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar4-27.img"
  Save memory "mem" to "test/ar4-27.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar4-28.input"
  Load memory "mem" from "test/ar4-28.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar4-28.img"
  Save memory "mem" to "test/ar4-28.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar4-29.input"
  Load memory "mem" from "test/ar4-29.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar4-29.img"
  Save memory "mem" to "test/ar4-29.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar4-30.input"
  Load memory "mem" from "test/ar4-30.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar4-30.img"
  Save memory "mem" to "test/ar4-30.img" (text file)

  $ ls -1 test/*.img
  test/ar4-01.img
  test/ar4-02.img
  test/ar4-03.img
  test/ar4-04.img
  test/ar4-05.img
  test/ar4-06.img
  test/ar4-07.img
  test/ar4-08.img
  test/ar4-09.img
  test/ar4-10.img
  test/ar4-11.img
  test/ar4-12.img
  test/ar4-13.img
  test/ar4-14.img
  test/ar4-15.img
  test/ar4-16.img
  test/ar4-17.img
  test/ar4-18.img
  test/ar4-19.img
  test/ar4-20.img
  test/ar4-21.img
  test/ar4-22.img
  test/ar4-23.img
  test/ar4-24.img
  test/ar4-25.img
  test/ar4-26.img
  test/ar4-27.img
  test/ar4-28.img
  test/ar4-29.img
  test/ar4-30.img

  $ (cd test && ./check.sh "ar4" 30)
  Check diff for subleq files with prefix='ar4'
  diff ar4-01.img ar4-01.output
  diff ar4-02.img ar4-02.output
  diff ar4-03.img ar4-03.output
  diff ar4-04.img ar4-04.output
  diff ar4-05.img ar4-05.output
  diff ar4-06.img ar4-06.output
  diff ar4-07.img ar4-07.output
  diff ar4-08.img ar4-08.output
  diff ar4-09.img ar4-09.output
  diff ar4-10.img ar4-10.output
  diff ar4-11.img ar4-11.output
  diff ar4-12.img ar4-12.output
  diff ar4-13.img ar4-13.output
  diff ar4-14.img ar4-14.output
  diff ar4-15.img ar4-15.output
  diff ar4-16.img ar4-16.output
  diff ar4-17.img ar4-17.output
  diff ar4-18.img ar4-18.output
  diff ar4-19.img ar4-19.output
  diff ar4-20.img ar4-20.output
  diff ar4-21.img ar4-21.output
  diff ar4-22.img ar4-22.output
  diff ar4-23.img ar4-23.output
  diff ar4-24.img ar4-24.output
  diff ar4-25.img ar4-25.output
  diff ar4-26.img ar4-26.output
  diff ar4-27.img ar4-27.output
  diff ar4-28.img ar4-28.output
  diff ar4-29.img ar4-29.output
  diff ar4-30.img ar4-30.output
