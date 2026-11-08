#import "../lib/wiki.typ": *

#show: wiki-page.with(
  title: "List of projects",
  categories: ("Projects",),
)

This is a list of projects by #wlink("user-jinju")[Jinju], sorted by date.

#wikitable(columns: 4,
  [Year], [Project], [Platform], [Status],
  [2026], wlink("stm32-logger")[STM32 sensor logger], [STM32F4], [Active],
  [2025], wlink("project-two")[Project two], [[MCU]], [Planned],
)
