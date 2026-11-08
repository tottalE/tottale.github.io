#import "../lib/wiki.typ": *

// 메인 페이지 (포털). 카테고리 박스는 문서의 categories: 를 보고 자동으로 채워져요.
#show: wiki-page.with(title: "Main Page", main-page: true)

#welcome([Welcome to #site.name,])[
  a personal wiki about embedded systems and #wlink("stm32")[STM32] microcontrollers.
]

#side-by-side(columns: (2fr, 1fr))[
  #portal-box("About me", color: "blue")[
    Hi, I'm *Jinju* — a Korean engineering student in Germany, learning #wlink("embedded-systems")[embedded systems] by reading reference manuals and building small projects on #wlink("stm32")[STM32]. This wiki is my notebook: short notes, things I got stuck on, and the #wlink("projects")[projects] I built.

    #more(wlink("user-jinju")[→ More about me])
  ]
][
  #portal-box("Recent changes", color: "green", id: "recent-changes", recent-changes(n: 3))
]

#portal-grid()

#more(link("categories.html")[→ All categories])
