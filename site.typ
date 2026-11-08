// 사이트 전체 설정 — 여기만 바꾸면 모든 페이지에 반영돼요.
#let site = (
  name: "JinjuWiki",
  tagline: "The personal MCUpedia",
  logo: "O",                 // 로고 그림이 없을 때 쓰는 글자
  // 로고 그림 (assets/ 안의 파일). 사진을 쓰려면 assets/에 넣고 "photo.jpg" 처럼 적기. 없으면 none
  logo-image: "logo.svg",
  // 왼쪽 사이드바 메뉴. href 가 "#random" 이면 랜덤 문서 버튼이 돼요.
  nav: (
    ("Main page", "index.html"),
    ("Recent changes", "index.html#recent-changes"),
    ("Random page", "#random"),
    ("About me", "user-jinju.html"),
  ),
  elsewhere: (
    ("GitHub", "https://github.com/tottale"),
    ("LinkedIn", "https://www.linkedin.com/in/jinjuok"),
  ),
  // 메인 페이지에 보일 카테고리 박스 (이름, 설명).
  // 문서의 categories: 에 같은 이름을 쓰면 그 박스에 자동으로 들어가요.
  portal: (
    ("STM32", ""),
    ("MCU Basics", ""),
    ("Peripherals", "UART, I²C, SPI, timers, ADC, DMA"),
    ("C Programming", "Embedded C: pointers, volatile, bit operations"),
    ("Literatures", ""),
    ("Projects", "Things I built"),
    ("Courses", "Courses I've taken at HAW."),
  ),
)
