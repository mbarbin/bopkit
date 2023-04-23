// Constants can be addresses or values. Let's check it out!
define a 0
define b 1
define one #1
define two #2
define four #4

// a <- one + two
load one, R0
load two, R1
add
store R1, a

// b <- one + two + three
load four, R0
add
store R1, b

// export the values computed to the output device
load a, R0
load b, R1
write R0, 0
write R1, 1
