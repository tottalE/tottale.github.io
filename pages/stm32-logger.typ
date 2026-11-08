#import "../lib/wiki.typ": *

#show: wiki-page.with(
  title: "STM32 sensor logger",
  categories: ("Projects", "STM32"),
)

#infobox(
  title: "STM32 sensor logger",
  ("Developer", wlink("user-jinju")[Jinju]),
  ("Started", [2026]),
  ("Platform", [#wlink("stm32")[STM32F4] (ARM Cortex-M4)]),
  ("Language", wlink("c-language")[C]),
  ("Status", [Active]),
  ("Source", link("https://github.com/tottale/stm32-logger")[GitHub]),
)

The *STM32 sensor logger* is a bare-metal data logger written in #wlink("c-language")[C] for an #wlink("stm32")[STM32] microcontroller, developed by #wlink("user-jinju")[Jinju].#note[Source code on GitHub.] It reads a sensor over #wlink("i2c")[I²C] and streams the values over #wlink("uart")[UART].

#toc()

= Background
[Why you built it.]

= Design
== Hardware
[Board, sensor, wiring.]

```mermaid
flowchart LR
  MCU[STM32F4] -->|I2C| S[Sensor]
  MCU -->|UART| PC[PC terminal]
  S -.->|IRQ| MCU
```

== Firmware
[Register-level setup, timers, interrupts.]

```c
// Code blocks work too
RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
```

#tip[Enable the peripheral clock in `RCC` before touching any GPIO register — otherwise writes are silently ignored.]

= Lessons learned
[What you learned.]

= See also
- #wlink("projects")[List of projects]
- #wlink("embedded-systems")[Embedded systems]

= References
#references()
