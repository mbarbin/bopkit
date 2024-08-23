  $ bopkit simu or.bop --num-counter-cycles 1
     Cycle | a[0] a[1] a[2] a[3] | s
         0 | 0 0 0 0 | 0
         1 | 1 0 0 0 | 1
         2 | 0 1 0 0 | 1
         3 | 1 1 0 0 | 1
         4 | 0 0 1 0 | 1
         5 | 1 0 1 0 | 1
         6 | 0 1 1 0 | 1
         7 | 1 1 1 0 | 1
         8 | 0 0 0 1 | 1
         9 | 1 0 0 1 | 1
        10 | 0 1 0 1 | 1
        11 | 1 1 0 1 | 1
        12 | 0 0 1 1 | 1
        13 | 1 0 1 1 | 1
        14 | 0 1 1 1 | 1
        15 | 1 1 1 1 | 1

  $ bopkit simu orn.bop --num-counter-cycles 1
     Cycle | a[0][0] a[0][1] a[1][0] a[1][1] a[2][0] a[2][1] | s[0] s[1]
         0 | 0 0 0 0 0 0 | 0 0
         1 | 1 0 0 0 0 0 | 1 0
         2 | 0 1 0 0 0 0 | 0 1
         3 | 1 1 0 0 0 0 | 1 1
         4 | 0 0 1 0 0 0 | 1 0
         5 | 1 0 1 0 0 0 | 1 0
         6 | 0 1 1 0 0 0 | 1 1
         7 | 1 1 1 0 0 0 | 1 1
         8 | 0 0 0 1 0 0 | 0 1
         9 | 1 0 0 1 0 0 | 1 1
        10 | 0 1 0 1 0 0 | 0 1
        11 | 1 1 0 1 0 0 | 1 1
        12 | 0 0 1 1 0 0 | 1 1
        13 | 1 0 1 1 0 0 | 1 1
        14 | 0 1 1 1 0 0 | 1 1
        15 | 1 1 1 1 0 0 | 1 1
        16 | 0 0 0 0 1 0 | 1 0
        17 | 1 0 0 0 1 0 | 1 0
        18 | 0 1 0 0 1 0 | 1 1
        19 | 1 1 0 0 1 0 | 1 1
        20 | 0 0 1 0 1 0 | 1 0
        21 | 1 0 1 0 1 0 | 1 0
        22 | 0 1 1 0 1 0 | 1 1
        23 | 1 1 1 0 1 0 | 1 1
        24 | 0 0 0 1 1 0 | 1 1
        25 | 1 0 0 1 1 0 | 1 1
        26 | 0 1 0 1 1 0 | 1 1
        27 | 1 1 0 1 1 0 | 1 1
        28 | 0 0 1 1 1 0 | 1 1
        29 | 1 0 1 1 1 0 | 1 1
        30 | 0 1 1 1 1 0 | 1 1
        31 | 1 1 1 1 1 0 | 1 1
        32 | 0 0 0 0 0 1 | 0 1
        33 | 1 0 0 0 0 1 | 1 1
        34 | 0 1 0 0 0 1 | 0 1
        35 | 1 1 0 0 0 1 | 1 1
        36 | 0 0 1 0 0 1 | 1 1
        37 | 1 0 1 0 0 1 | 1 1
        38 | 0 1 1 0 0 1 | 1 1
        39 | 1 1 1 0 0 1 | 1 1
        40 | 0 0 0 1 0 1 | 0 1
        41 | 1 0 0 1 0 1 | 1 1
        42 | 0 1 0 1 0 1 | 0 1
        43 | 1 1 0 1 0 1 | 1 1
        44 | 0 0 1 1 0 1 | 1 1
        45 | 1 0 1 1 0 1 | 1 1
        46 | 0 1 1 1 0 1 | 1 1
        47 | 1 1 1 1 0 1 | 1 1
        48 | 0 0 0 0 1 1 | 1 1
        49 | 1 0 0 0 1 1 | 1 1
        50 | 0 1 0 0 1 1 | 1 1
        51 | 1 1 0 0 1 1 | 1 1
        52 | 0 0 1 0 1 1 | 1 1
        53 | 1 0 1 0 1 1 | 1 1
        54 | 0 1 1 0 1 1 | 1 1
        55 | 1 1 1 0 1 1 | 1 1
        56 | 0 0 0 1 1 1 | 1 1
        57 | 1 0 0 1 1 1 | 1 1
        58 | 0 1 0 1 1 1 | 1 1
        59 | 1 1 0 1 1 1 | 1 1
        60 | 0 0 1 1 1 1 | 1 1
        61 | 1 0 1 1 1 1 | 1 1
        62 | 0 1 1 1 1 1 | 1 1
        63 | 1 1 1 1 1 1 | 1 1
