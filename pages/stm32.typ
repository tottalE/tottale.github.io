#import "../lib/wiki.typ": *

#show: wiki-page.with(
  title: "STM32",
  categories: ("STM32",),
)

*STM32* is a family of 32-bit #wlink("embedded-systems")[microcontrollers] based on ARM Cortex-M cores. Jinju uses it in the #wlink("stm32-logger")[STM32 sensor logger].

#toc()

= Peripherals
Common peripherals include GPIO, timers, #wlink("uart")[UART], SPI and #wlink("i2c")[I²C].

= My notes
[Things you learned from the reference manual — clock tree, RCC, GPIO registers…]

#important[hello]

= See also
- #wlink("embedded-systems")[Embedded systems]
- #wlink("c-language")[C (programming language)]
