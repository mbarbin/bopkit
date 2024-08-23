  $ bopkit simu and.bop --num-counter-cycles 1
     Cycle | a[0] a[1] a[2] a[3] | s
         0 | 0 0 0 0 | 0
         1 | 1 0 0 0 | 0
         2 | 0 1 0 0 | 0
         3 | 1 1 0 0 | 0
         4 | 0 0 1 0 | 0
         5 | 1 0 1 0 | 0
         6 | 0 1 1 0 | 0
         7 | 1 1 1 0 | 0
         8 | 0 0 0 1 | 0
         9 | 1 0 0 1 | 0
        10 | 0 1 0 1 | 0
        11 | 1 1 0 1 | 0
        12 | 0 0 1 1 | 0
        13 | 1 0 1 1 | 0
        14 | 0 1 1 1 | 0
        15 | 1 1 1 1 | 1

  $ bopkit simu andn.bop --num-counter-cycles 1
     Cycle | a[0][0] a[0][1] a[1][0] a[1][1] a[2][0] a[2][1] | s[0] s[1]
         0 | 0 0 0 0 0 0 | 0 0
         1 | 1 0 0 0 0 0 | 0 0
         2 | 0 1 0 0 0 0 | 0 0
         3 | 1 1 0 0 0 0 | 0 0
         4 | 0 0 1 0 0 0 | 0 0
         5 | 1 0 1 0 0 0 | 0 0
         6 | 0 1 1 0 0 0 | 0 0
         7 | 1 1 1 0 0 0 | 0 0
         8 | 0 0 0 1 0 0 | 0 0
         9 | 1 0 0 1 0 0 | 0 0
        10 | 0 1 0 1 0 0 | 0 0
        11 | 1 1 0 1 0 0 | 0 0
        12 | 0 0 1 1 0 0 | 0 0
        13 | 1 0 1 1 0 0 | 0 0
        14 | 0 1 1 1 0 0 | 0 0
        15 | 1 1 1 1 0 0 | 0 0
        16 | 0 0 0 0 1 0 | 0 0
        17 | 1 0 0 0 1 0 | 0 0
        18 | 0 1 0 0 1 0 | 0 0
        19 | 1 1 0 0 1 0 | 0 0
        20 | 0 0 1 0 1 0 | 0 0
        21 | 1 0 1 0 1 0 | 1 0
        22 | 0 1 1 0 1 0 | 0 0
        23 | 1 1 1 0 1 0 | 1 0
        24 | 0 0 0 1 1 0 | 0 0
        25 | 1 0 0 1 1 0 | 0 0
        26 | 0 1 0 1 1 0 | 0 0
        27 | 1 1 0 1 1 0 | 0 0
        28 | 0 0 1 1 1 0 | 0 0
        29 | 1 0 1 1 1 0 | 1 0
        30 | 0 1 1 1 1 0 | 0 0
        31 | 1 1 1 1 1 0 | 1 0
        32 | 0 0 0 0 0 1 | 0 0
        33 | 1 0 0 0 0 1 | 0 0
        34 | 0 1 0 0 0 1 | 0 0
        35 | 1 1 0 0 0 1 | 0 0
        36 | 0 0 1 0 0 1 | 0 0
        37 | 1 0 1 0 0 1 | 0 0
        38 | 0 1 1 0 0 1 | 0 0
        39 | 1 1 1 0 0 1 | 0 0
        40 | 0 0 0 1 0 1 | 0 0
        41 | 1 0 0 1 0 1 | 0 0
        42 | 0 1 0 1 0 1 | 0 1
        43 | 1 1 0 1 0 1 | 0 1
        44 | 0 0 1 1 0 1 | 0 0
        45 | 1 0 1 1 0 1 | 0 0
        46 | 0 1 1 1 0 1 | 0 1
        47 | 1 1 1 1 0 1 | 0 1
        48 | 0 0 0 0 1 1 | 0 0
        49 | 1 0 0 0 1 1 | 0 0
        50 | 0 1 0 0 1 1 | 0 0
        51 | 1 1 0 0 1 1 | 0 0
        52 | 0 0 1 0 1 1 | 0 0
        53 | 1 0 1 0 1 1 | 1 0
        54 | 0 1 1 0 1 1 | 0 0
        55 | 1 1 1 0 1 1 | 1 0
        56 | 0 0 0 1 1 1 | 0 0
        57 | 1 0 0 1 1 1 | 0 0
        58 | 0 1 0 1 1 1 | 0 1
        59 | 1 1 0 1 1 1 | 0 1
        60 | 0 0 1 1 1 1 | 0 0
        61 | 1 0 1 1 1 1 | 1 0
        62 | 0 1 1 1 1 1 | 0 1
        63 | 1 1 1 1 1 1 | 1 1
