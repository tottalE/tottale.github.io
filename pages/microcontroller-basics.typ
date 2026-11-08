#import "../lib/wiki.typ": *

#show: wiki-page.with(
  title: "Microcontroller Basics",
  categories: ("MCU Basics",),
  created: "2026-11-08",
)

#toc()

= 1. Conversion from Binary to Hexadecimal

#important[*One hexadecimal digit is four binary digits.*]

#wikitable(columns: 2,
  [0x], [0b],
  [0], [0000],
  [1], [0001],
  [2], [0010],
  [3], [0011],
  [4], [0100],
  [5], [0101],
  [6], [0110],
  [7], [0111],
  [8], [1000],
  [9], [1001],
  [A], [1010],
  [B], [1011],
  [C], [1100],
  [D], [1101],
  [E], [1110],
  [F], [1111],
)

This allows you to easily convert hex numbers to binary one digit at a time, as you can see in the following example.

```
                  A    4    1    3    F
(0x) A413F ↔ (0b) 1010 0100 0001 0011 1111
```

= 2. The Concept of a Register

= 3. Bit Manipulation (using Registers)

= 4. Bit Masking
