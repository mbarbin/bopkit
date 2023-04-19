# 7-segment displays

<p>
  <img
    src="https://github.com/mbarbin/bopkit/blob/assets/image/digital-watch.png?raw=true"
    width='512'
    alt="Logo"
  />
</p>

This part of the stdlib implements graphical user interfaces in the form of
external blocks that can be connected to bopkit circuits.

## Digital watch

The interface displays a 7-segment display for a digital watch.

It is used in the
[digital-watch](https://github.com/mbarbin/bopkit/tree/main/project/digital-watch/)
project.

## Digital calendar

This displays adds the date in addition to the time of day.

It is used in the
[visa](https://github.com/mbarbin/bopkit/tree/main/project/visa/)
project.

## 7_segment.bop

<details open>
<summary>
Checkout the entire contents of the file 7_segment.bop
</summary>

<!-- $MDX file=7_segment.bop -->
```bopkit
/**
 * To produce the bits code to send to the 7-segment display, we use a ROM that
 * contains them. Since there are 10 codes, we need 4 bits of address.
 */
ROM Dec7 (4, 7) = text {

  // Zero   One    Two     Three   Four
  1011111 0000110 0111011 0101111 1100110

  // Five   Six    Seven   Eight   Nine
  1101101 1111101 0000111 1111111 1101111

  // The remaining 6 words are set to [false] since they are
  // not specified here.
}

external digital_watch_display "digital_watch_display.exe"

external digital_calendar_display "digital_calendar_display.exe"

digital_watch_display(h10:[7], h1:[7], m10:[7], m1:[7], s10:[7], s1:[7]) = ()
where
  external("digital_watch_display.exe",
    h10:[7],
    h1:[7],
    m10:[7],
    m1:[7],
    s10:[7],
    s1:[7]);
end where;
```

</details>
