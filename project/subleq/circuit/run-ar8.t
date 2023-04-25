Hello

  $ ls -1 test/*.img
  ls: cannot access 'test/*.img': No such file or directory
  [2]

  $ bopkit simu main.bop \
  >   -parameter 'DEBUG=0' \
  >   -parameter 'AR=8' \
  >   -parameter 'NumberOfPrograms=10' \
  >   -parameter 'FilesPrefix=test/ar8-'
  [ <-- ] Loading RAM <-- "test/ar8-01.input"
  Load memory "mem" from "test/ar8-01.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-01.img"
  Save memory "mem" to "test/ar8-01.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar8-02.input"
  Load memory "mem" from "test/ar8-02.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-02.img"
  Save memory "mem" to "test/ar8-02.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar8-03.input"
  Load memory "mem" from "test/ar8-03.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-03.img"
  Save memory "mem" to "test/ar8-03.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar8-04.input"
  Load memory "mem" from "test/ar8-04.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-04.img"
  Save memory "mem" to "test/ar8-04.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar8-05.input"
  Load memory "mem" from "test/ar8-05.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-05.img"
  Save memory "mem" to "test/ar8-05.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar8-06.input"
  Load memory "mem" from "test/ar8-06.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-06.img"
  Save memory "mem" to "test/ar8-06.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar8-07.input"
  Load memory "mem" from "test/ar8-07.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-07.img"
  Save memory "mem" to "test/ar8-07.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar8-08.input"
  Load memory "mem" from "test/ar8-08.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-08.img"
  Save memory "mem" to "test/ar8-08.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar8-09.input"
  Load memory "mem" from "test/ar8-09.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-09.img"
  Save memory "mem" to "test/ar8-09.img" (text file)
  [ <-- ] Loading RAM <-- "test/ar8-10.input"
  Load memory "mem" from "test/ar8-10.input" (text file)
  RESET !!
  [ --> ] Saving RAM --> "test/ar8-10.img"
  Save memory "mem" to "test/ar8-10.img" (text file)
  ("External block exception" ((name disk_interface) (index_cycle 27117))
   ((line 000000000110111111)) (Dune__exe__Disk_interface.End_of_execution))
  File "main.bop", line 24, characters 6-114:
  24 |       $disk_interface[AR](
  25 |         cr_address:[AR],
  26 |         cr_write,
  27 |         cr_data_in:[AR],
  28 |         cr_standby));
  Error: External process[1] ('./disk_interface.exe -AR 8 -DEBUG 0
  -num-programs 10 -files-prefix test/ar8-')
  received: '000000000110111111' and exited abnormally.
  [1]

  $ ls -1 test/*.img
  test/ar8-01.img
  test/ar8-02.img
  test/ar8-03.img
  test/ar8-04.img
  test/ar8-05.img
  test/ar8-06.img
  test/ar8-07.img
  test/ar8-08.img
  test/ar8-09.img
  test/ar8-10.img

  $ (cd test && ./check.sh "ar8" 10)
  Check diff for subleq files with prefix='ar8'
  diff ar8-01.img ar8-01.output
  diff ar8-02.img ar8-02.output
  diff ar8-03.img ar8-03.output
  diff ar8-04.img ar8-04.output
  diff ar8-05.img ar8-05.output
  diff ar8-06.img ar8-06.output
  diff ar8-07.img ar8-07.output
  diff ar8-08.img ar8-08.output
  diff ar8-09.img ar8-09.output
  diff ar8-10.img ar8-10.output
