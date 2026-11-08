#import "../lib/wiki.typ": *
#import "@preview/wavy:0.1.3"

#show: wiki-page.with(
  title: "UART",
  categories: ("Peripherals",),
)

A *UART* (universal asynchronous receiver-transmitter) is a serial communication peripheral found on almost every microcontroller, including #wlink("stm32")[STM32].

= How it works
[Start bit, data bits, parity, stop bit, baud rate…]

One frame in the common *8N1* format (8 data bits, no parity, 1 stop bit). The line idles high.

#draw(width: 13cm, wavy.render(`{signal: [
  {name: "TX", wave: "1.0========1.", data: ["D0","D1","D2","D3","D4","D5","D6","D7"]},
]}`.text))

The frame starts with a low *start bit*, then 8 data bits (LSB first), then a high *stop bit*.

= Used in
- #wlink("stm32-logger")[STM32 sensor logger]

= See also
- #wlink("i2c")[I²C]
- #wlink("spi")[SPI]
