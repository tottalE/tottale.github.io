#import "../lib/wiki.typ": *

#show: wiki-page.with(
  title: "I²C",
  categories: ("Peripherals",),
)

*I²C* (Inter-Integrated Circuit) is a two-wire serial bus (SDA and SCL) used to connect sensors and other chips to a microcontroller such as #wlink("stm32")[STM32].

= How it works
[Addressing, start/stop conditions, ACK/NACK, pull-up resistors…]

= Used in
- #wlink("stm32-logger")[STM32 sensor logger]

= See also
- #wlink("uart")[UART]
- #wlink("spi")[SPI]
