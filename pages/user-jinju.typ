#import "../lib/wiki.typ": *

#show: wiki-page.with(
  title: "About me",
  hatnote: [This article is about the engineer. For other uses, see #wlink("jinju-disambiguation")[Jinju (disambiguation)].],
  categories: ("Embedded engineers", "Korean expatriates in Germany", "Living people"),
)

#infobox(
  title: "Jinju",
  // 사진을 넣으려면 assets/photo.jpg 를 넣고 아래 줄 주석 해제
  // image: "photo.jpg", caption: [Jinju in 2026],
  ("Born", [Republic of Korea]),
  ("Residence", [Germany]),
  ("Education", [[University name] \ [Degree, field]]),
  ("Occupation", [Student, #wlink("embedded-systems")[embedded] engineer]),
  ("Known for", wlink("stm32-logger")[STM32 sensor logger]),
  section("Skills"),
  ("Programming", [#wlink("c-language")[C], C++, Python]),
  ("Hardware", [#wlink("stm32")[STM32], ARM Cortex-M]),
  ("Spoken", [Korean (native), English, German]),
  section("Links"),
  ("GitHub", link("https://github.com/tottale")[\@tottale]),
)

*Jinju* is a South Korean engineering student based in Germany, working on #wlink("embedded-systems")[embedded systems] and #wlink("stm32")[microcontroller] programming.#note[“About me”. _JinjuWiki_.] She is currently studying [field] at [university] and is looking for Werkstudent positions in embedded software.

She is known for the #wlink("stm32-logger")[STM32 sensor logger] and for writing about learning MCUs from reference manuals.

#toc()

= Early life and education
Jinju was born and raised in South Korea. She became interested in [what got you started] at an early age. In [year] she moved to Germany to study [field] at [university].

= Career
[Internships, part-time jobs, research assistant roles. Write it in the third person, like an encyclopedia.]

#wikitable(columns: 3,
  [Years], [Organisation], [Role],
  [2025–present], [[University lab]], [Student assistant],
  [2023–2024], [[Company]], [Intern],
)

= Projects
See also: #wlink("projects")[List of projects].

== STM32 sensor logger
A bare-metal logger on an #wlink("stm32")[STM32] board that reads a sensor over #wlink("i2c")[I²C] and streams data over #wlink("uart")[UART]. See the #wlink("stm32-logger")[main article].

== [Project two]
[Description.] #wlink("project-two")[More documentation] is planned.

= Skills
- *Programming:* #wlink("c-language")[C], C++, Python
- *Embedded:* register-level & HAL, GPIO, #wlink("uart")[UART], SPI, #wlink("i2c")[I²C], timers, interrupts
- *Tools:* STM32CubeIDE, Git, oscilloscope, logic analyser

= Personal life
Outside of engineering, Jinju enjoys [hobbies]. She lives in [city].

= Contact
- Email: #link("mailto:you@example.com")[you\@example.com]
- LinkedIn: #link("https://www.linkedin.com/in/jinjuok")[linkedin.com/in/jinjuok]

= References
#references()
