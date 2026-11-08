// 위키 스타일 템플릿
//  - build.sh (HTML export) 로 빌드하면 → 위키 사이트 모양
//  - VS Code + Tinymist 같은 보통 Typst 미리보기(PDF) 에서는 → 보고서 모양
// 그래서 문서는 평소 보고서 쓰듯이 쓰고, 옆 미리보기로 바로 확인할 수 있어요.
#import "../site.typ": site
// Mermaid 도식: ```mermaid 코드 블록을 그림으로 (PDF 미리보기에서도 바로 보여요)
#import "@preview/pelermaid:0.1.0": show-mermaid-blocks

// ---------- helpers ----------
// 지금 HTML 로 빌드 중인지 (context 안에서만 쓸 수 있어요)
#let is-html() = target() == "html"

#let a(href, body, ..extra) = html.elem("a", attrs: (href: href, ..extra.named()), body)

// content -> 일반 문자열 (heading id 만들 때 사용)
#let plain(c) = {
  if c == none { "" }
  else if type(c) == str { c }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).sum(default: "") }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let slug(s) = lower(s).trim().replace(regex("[^\\p{L}\\p{N}]+"), "-").trim("-")

#let link-blue = rgb("#0645ad")
#let link-red = rgb("#ba0000")
#let muted = rgb("#54595d")

// ---------- 위키 내부 링크 ----------
// 사용법: #wlink("stm32-logger")[STM32 logger]
// 없는 문서로 가는 링크는 위키백과처럼 빨간색으로 표시돼요 (build.sh 로 빌드할 때).
#let wlink(target, ..body) = context {
  let label = body.pos().at(0, default: target)
  let existing = sys.inputs.at("pages", default: none)
  let missing = existing != none and target not in existing.split(",")
  if is-html() {
    let attrs = (href: target + ".html")
    if missing {
      attrs.insert("class", "new")
      attrs.insert("title", target + " (page does not exist)")
    }
    html.elem("a", attrs: attrs, label)
  } else {
    text(fill: if missing { link-red } else { link-blue }, label)
  }
}

// ---------- 각주 / References ----------
#let notes = state("wiki-notes", ())

// 사용법: 문장 끝에 #note[출처 설명]   (미리보기에서는 보통 각주로 보여요)
#let note(body) = context {
  if is-html() {
    notes.update(n => n + (body,))
    context {
      let i = str(notes.get().len())
      html.elem("sup", attrs: (class: "ref", id: "cite-" + i), a("#ref-" + i, "[" + i + "]"))
    }
  } else {
    footnote(body)
  }
}

// 사용법: = References 아래에 #references()
#let references() = context {
  if is-html() {
    let all = notes.final()
    html.elem("ol", attrs: (class: "refs"), for (i, body) in all.enumerate() {
      let n = str(i + 1)
      html.elem("li", attrs: (id: "ref-" + n), {
        a("#cite-" + n, "↑", class: "back")
        [ ]
        body
      })
    })
  } else {
    text(size: 9pt, fill: muted, emph[(See the footnotes.)])
  }
}

// ---------- 인포박스 ----------
#let section(name) = (section: name)

// 사용법:
// #infobox(title: "Jinju", image: "photo.jpg", caption: [Jinju in 2026],
//   ("Born", [Korea]),
//   section("Skills"),
//   ("Languages", [C, Python]),
// )
#let infobox(title: none, image: none, caption: none, ..rows) = context {
  if is-html() {
    html.elem("table", attrs: (class: "infobox"), {
      if title != none { html.elem("caption", title) }
      if image != none {
        html.elem("tr", html.elem("td", attrs: (colspan: "2", class: "photo"), {
          html.elem("img", attrs: (src: image, alt: plain(title)))
          if caption != none { html.elem("div", attrs: (class: "cap"), caption) }
        }))
      }
      for r in rows.pos() {
        if type(r) == dictionary {
          html.elem("tr", html.elem("td", attrs: (colspan: "2", class: "sect"), r.section))
        } else {
          html.elem("tr", {
            html.elem("th", r.at(0))
            html.elem("td", r.at(1))
          })
        }
      }
    })
  } else {
    // 보고서 모양: 오른쪽 정렬된 작은 표
    align(right, block(width: 48%, stroke: 0.5pt + luma(160), fill: luma(248), inset: 6pt, {
      set text(size: 8.5pt)
      set align(left)
      if title != none { align(center, text(size: 10.5pt, weight: "bold", title)) }
      if image != none {
        align(center, std.image("/assets/" + image, width: 80%))
        if caption != none { align(center, caption) }
      }
      table(
        columns: (38%, 1fr), stroke: none, inset: 3pt,
        ..rows.pos().map(r => if type(r) == dictionary {
          (table.cell(colspan: 2, fill: rgb("#dde4f0"), align(center, strong(r.section))),)
        } else {
          (strong(r.at(0)), r.at(1))
        }).flatten()
      )
    }))
  }
}

// ---------- 표 ----------
// 사용법: 첫 줄(columns 개)이 제목 줄이 돼요.
// #wikitable(columns: 3,
//   [Year], [Project], [Status],
//   [2026], [Logger], [Active],
// )
#let wikitable(columns: 2, ..cells) = context {
  let cs = cells.pos()
  if is-html() {
    html.elem("table", attrs: (class: "wikitable"), {
      for (r, row) in cs.chunks(columns).enumerate() {
        html.elem("tr", for c in row { html.elem(if r == 0 { "th" } else { "td" }, c) })
      }
    })
  } else {
    table(
      columns: columns, stroke: 0.5pt + luma(160), inset: 5pt,
      fill: (_, y) => if y == 0 { luma(234) } else { luma(248) },
      ..cs.enumerate().map(((i, c)) => if i < columns { strong(c) } else { c })
    )
  }
}

// ---------- 메모 상자 (alertoni 스타일: 둥근 테두리 + 테두리 위 제목) ----------
// 사용법: #tip[...]  #info[...]  #important[...]  #warning[...]  #caution[...]
//        제목 바꾸기: #warning(title: "Pitfall")[...]
//        제목 없이:   #tip(title: none)[...]
// (#note 는 각주용이라서, 일반 메모는 #info 를 써요)
#let callout-kinds = (
  info: ("Info", rgb("#0969da")),
  tip: ("Tip", rgb("#1a7f37")),
  important: ("Important", rgb("#8250df")),
  warning: ("Warning", rgb("#9a6700")),
  caution: ("Caution", rgb("#d1242f")),
)
#let callout(kind, title: auto, body) = context {
  let (default-title, color) = callout-kinds.at(kind)
  let t = if title == auto { default-title } else { title }
  if is-html() {
    html.elem("div", attrs: (class: "callout", style: "--c:" + color.to-hex()), {
      if t != none { html.elem("p", attrs: (class: "callout-title"), t) }
      body
    })
  } else {
    // alertoni 스타일: 얇은 둥근 테두리 + 테두리 위에 걸친 제목
    let pad = 8pt
    let tint = color.lighten(93%)   // 안쪽 연한 색
    block(width: 100%, stroke: 1.2pt + color, fill: tint, radius: 4pt, inset: (x: 10pt, top: pad + 2pt, bottom: pad),
      above: 1.4em, below: 1em, {
        if t != none {
          place(top + left, dx: -2pt, dy: -pad - 2pt - 0.36em,
            // 제목 배경: 위쪽 반은 바깥(흰색), 아래쪽 반은 안쪽(연한 색) 이라 선만 가려져요
            box(fill: gradient.linear((white, 0%), (white, 50%), (tint, 50%), (tint, 100%), dir: ttb), inset: (x: 3pt), text(fill: color, weight: "bold", size: 0.95em, t)))
        }
        body
      })
  }
}
#let info(title: auto, body) = callout("info", title: title, body)
#let tip(title: auto, body) = callout("tip", title: title, body)
#let important(title: auto, body) = callout("important", title: title, body)
#let warning(title: auto, body) = callout("warning", title: title, body)
#let caution(title: auto, body) = callout("caution", title: title, body)

// ---------- 그림 (패키지로 그린 도식 등) ----------
// 사이트(HTML)에서는 align, grid, 도형, 글자색 같은 게 빠져요.
// #draw[...] 로 감싸면 사이트에서도 그림(SVG)으로 똑같이 나와요.
// 사용법:
//   #import "@preview/wavy:0.1.3"
//   #draw(wavy.render(`{signal: [{name: "TX", wave: "10.1"}]}`.text))
// width: 그림을 그릴 폭 (사이트에서는 화면에 맞게 줄어들어요)
#let draw(width: 15cm, body) = context {
  if is-html() {
    html.elem("div", attrs: (class: "draw"), html.frame(block(width: width, body)))
  } else {
    align(center, body)
  }
}

// ```mermaid 코드 블록 → 그림
#let mermaid-block = show-mermaid-blocks(width: 65%)  // 도식 크기 (페이지 폭 대비)

// ---------- 목차 ----------
// 사용법: 도입부 문단 뒤에 #toc()
#let html-toc() = {
  let hs = query(heading.where(outlined: true)).filter(h => h.level <= 2)
  let n1 = 0
  let n2 = 0
  let items = ()
  for h in hs {
    if h.level == 1 {
      n1 += 1
      n2 = 0
      items.push((h, str(n1)))
    } else {
      n2 += 1
      items.push((h, str(n1) + "." + str(n2)))
    }
  }
  if items.len() > 0 {
    html.elem("div", attrs: (class: "toc"), {
      html.elem("b", "Contents")
      html.elem("ul", for (h, num) in items {
        html.elem("li", attrs: (class: "lv" + str(h.level)), a("#" + slug(plain(h.body)), {
          html.elem("span", attrs: (class: "num"), num)
          [ ]
          h.body
        }))
      })
    })
  }
}

#let toc() = context {
  if not is-html() {
    block(stroke: 0.5pt + luma(160), fill: luma(248), inset: 8pt, outline(title: [Contents], depth: 2))
  } else { html-toc() }
}

// ---------- 문서 목록 (build.sh 가 만드는 build/index.json) ----------
// 각 항목: (slug, title, categories, order, updated)
// 미리보기에서는 이 목록이 없어서 비어 있어요 (메인 페이지 박스가 비어 보이는 건 정상).
#let wiki-index = {
  let p = sys.inputs.at("index", default: none)
  if p == none { () } else { json(p) }
}
#let this-page = sys.inputs.at("page", default: none)

#let cat-href(name) = "category-" + slug(name) + ".html"
// 카테고리 안 문서 순서: order 가 있으면 그 숫자 순, 없으면 뒤로 가서 제목 순
#let page-order(p) = { let o = p.at("order", default: none); if o == none { 9999 } else { o } }
#let pages-in(cat) = wiki-index.filter(p => cat in p.categories).sorted(key: p => (page-order(p), lower(p.title)))
#let recent-pages(n) = {
  let ps = wiki-index.filter(p => p.slug != "index").sorted(key: p => p.updated).rev()
  ps.slice(0, calc.min(n, ps.len()))
}
#let page-link(p) = a(p.slug + ".html", p.title)

// ---------- 메인 포털용 ----------
// 사용법: #portal-box("Welcome", color: "blue")[내용]
#let portal-box(title, color: "blue", id: none, body) = context {
  if is-html() {
    let attrs = (class: "pbox pbox-" + color)
    if id != none { attrs.insert("id", id) }
    html.elem("div", attrs: attrs, {
      html.elem("h2", attrs: (class: "pbox-title"), title)
      html.elem("div", attrs: (class: "pbox-body"), body)
    })
  } else {
    block(width: 100%, stroke: 0.5pt + luma(170), inset: 0pt, {
      block(width: 100%, fill: luma(235), inset: 6pt, below: 0pt, strong(title))
      block(width: 100%, inset: 8pt, body)
    })
  }
}

// 카테고리 하나 → 문서 목록 박스
#let category-box(name, desc) = context {
  let ps = pages-in(name)
  if is-html() {
    portal-box(a(cat-href(name), name), color: "grey", {
      html.elem("p", attrs: (class: "pdesc"), desc)
      if ps.len() == 0 {
        html.elem("p", attrs: (class: "empty"), "No pages yet.")
      } else {
        html.elem("ul", for p in ps { html.elem("li", page-link(p)) })
      }
    })
  } else {
    portal-box(name, color: "grey", {
      text(fill: muted, desc)
      if ps.len() > 0 { list(..ps.map(p => p.title)) }
    })
  }
}

// 메인의 카테고리 박스 격자 (site.typ 의 portal 목록)
#let portal-grid() = context {
  if is-html() {
    html.elem("div", attrs: (class: "portal-grid"), for (name, desc) in site.portal { category-box(name, desc) })
  } else {
    grid(columns: (1fr, 1fr), gutter: 8pt, ..site.portal.map(((name, desc)) => category-box(name, desc)))
  }
}

// 최근 수정된 문서
#let recent-changes(n: 8) = context {
  if is-html() {
    html.elem("ul", attrs: (class: "recent"), for p in recent-pages(n) {
      html.elem("li", {
        html.elem("span", attrs: (class: "date"), p.updated)
        [ ]
        page-link(p)
      })
    })
  } else if wiki-index.len() == 0 {
    text(fill: muted, emph[(Filled in when the site is built.)])
  } else {
    list(..recent-pages(n).map(p => [#p.updated #p.title]))
  }
}

// 메인 맨 위 환영 배너
#let welcome(title, body, count: true) = context {
  if is-html() {
    html.elem("div", attrs: (class: "welcome"), {
      html.elem("div", attrs: (class: "welcome-title"), title)
      html.elem("div", body)
      if count {
        html.elem("div", attrs: (class: "count"), str(wiki-index.len()) + " articles · " + str(site.portal.len()) + " portals")
      }
    })
  } else {
    align(center, block(width: 100%, fill: rgb("#f5faff"), stroke: 0.5pt + rgb("#cedff2"), inset: 10pt, {
      text(size: 18pt, title)
      linebreak()
      body
    }))
  }
}

// 두 칸 나란히 (예: 메인의 About me | Recent changes). 좁은 화면에선 위아래로
// 사용법: #side-by-side(columns: (2fr, 1fr))[왼쪽][오른쪽]
#let side-by-side(columns: (2fr, 1fr), left, right) = context {
  if is-html() {
    let cols = columns.map(c => str(c / 1fr) + "fr").join(" ")
    html.elem("div", attrs: (class: "row", style: "grid-template-columns:" + cols), { left; right })
  } else {
    grid(columns: columns, gutter: 8pt, left, right)
  }
}

// 오른쪽 정렬 작은 링크 줄 (예: → More about me)
#let more(body) = context {
  if is-html() { html.elem("p", attrs: (class: "more"), body) } else { align(right, body) }
}

// ---------- 페이지 전체: HTML (위키 사이트) ----------
// 제목 밑 날짜 줄: "Created 2026-11-01 · Last edited 2026-11-08"
#let date-line(created, edited) = {
  let c = if created == none { none } else { str(created) }
  let parts = ()
  if c != none { parts.push("Created " + c) }
  if edited != none and edited != c { parts.push("Last edited " + edited) }
  parts.join(" · ", default: "")
}

#let html-page(title: "", hatnote: none, categories: (), main-page: false, created: none, body) = {
  // = 제목 → <h2 id="...">  (h1 은 문서 제목용)
  show heading: it => html.elem(
    "h" + str(calc.min(it.level + 1, 6)),
    attrs: (id: slug(plain(it.body))),
    it.body,
  )

  // 위키백과 로고 글꼴(Linux Libertine)과 같은 계열인 Libertinus Serif
  html.elem("link", attrs: (rel: "stylesheet", href: "https://fonts.googleapis.com/css2?family=Libertinus+Serif:wght@400;600&display=swap"))
  html.elem("link", attrs: (rel: "stylesheet", href: "wiki.css"))
  if site.at("logo-image", default: none) != none {
    html.elem("link", attrs: (rel: "icon", href: site.logo-image))  // 브라우저 탭 아이콘
  }
  html.elem("meta", attrs: (name: "viewport", content: "width=device-width, initial-scale=1"))
  // 검색/랜덤 문서용 문서 목록
  html.elem("script", "window.WIKI_INDEX=" + json.encode(wiki-index.map(p => (slug: p.slug, title: p.title)), pretty: false) + ";")
  html.elem("script", attrs: (src: "wiki.js", defer: "defer"))

  let me = wiki-index.find(p => p.slug == this-page)

  html.elem("div", attrs: (id: "page"), {
    // ----- 왼쪽: 로고 + 메뉴 -----
    html.elem("div", attrs: (id: "side"), {
      a("index.html", class: "logo", title: "Visit the main page", {
        let img = site.at("logo-image", default: none)
        if img != none {
          html.elem("img", attrs: (class: "logo-img", src: img, alt: ""))
        } else {
          html.elem("span", attrs: (class: "logo-mark"), site.logo)
        }
        html.elem("span", attrs: (class: "logo-text"), {
          site.name
          html.elem("small", site.tagline)
        })
      })
      html.elem("div", attrs: (class: "portlet"), {
        html.elem("h3", "Navigation")
        html.elem("ul", for (label, href) in site.nav {
          html.elem("li", if href == "#random" { a("#", label, class: "random-page") } else { a(href, label) })
        })
      })
      // 카테고리 트리: 항상 모든 카테고리를 보여 주고, 지금 문서가 속한 카테고리만 펼쳐요.
      // (지금 문서 아래엔 소제목 목차)
      let is-here(name) = (me != none and name in me.categories) or sys.inputs.at("cat", default: none) == name
      html.elem("div", attrs: (class: "portlet tree"), {
        html.elem("h3", "Categories")
        for (name, _) in site.portal {
          let ps = pages-in(name)
          html.elem("details", attrs: if is-here(name) { (open: "open") } else { (:) }, {
            html.elem("summary", { name; [ ]; html.elem("span", attrs: (class: "count"), "(" + str(ps.len()) + ")") })
            html.elem("ul", {
              for p in ps {
                let cur = p.slug == this-page
                html.elem("li", attrs: if cur { (class: "cur") } else { (:) }, {
                  page-link(p)
                  if cur {
                    context {
                      let hs = query(heading.where(level: 1)).filter(h => plain(h.body) != "References")
                      if hs.len() > 0 {
                        html.elem("ul", attrs: (class: "subtoc"), for h in hs {
                          html.elem("li", a("#" + slug(plain(h.body)), plain(h.body)))
                        })
                      }
                    }
                  }
                })
              }
              if ps.len() == 0 { html.elem("li", attrs: (class: "empty"), "No pages yet") }
              html.elem("li", attrs: (class: "catpage"), a(cat-href(name), "Category page →"))
            })
          })
        }
      })
      html.elem("div", attrs: (class: "portlet"), {
        html.elem("h3", "Elsewhere")
        html.elem("ul", for (label, href) in site.elsewhere { html.elem("li", a(href, label)) })
      })
    })

    // ----- 오른쪽: 탭 + 본문 -----
    html.elem("div", attrs: (id: "right"), {
      html.elem("div", attrs: (id: "head"), {
        html.elem("div", attrs: (class: "tabs"), {
          // 메인 페이지와 About me(user-jinju) 에는 [Main Page | About me] 탭 두 개
          if main-page {
            html.elem("span", attrs: (class: "on"), "Main Page")
            a("user-jinju.html", "About me")
          } else if this-page == "user-jinju" {
            a("index.html", "Main Page")
            html.elem("span", attrs: (class: "on"), "About me")
          } else {
            html.elem("span", attrs: (class: "on"), if title.starts-with("Category:") { "Category" } else { "Article" })
          }
        })
        html.elem("div", attrs: (class: "tabs"), {
          html.elem("form", attrs: (class: "search", action: "#"), {
            html.elem("input", attrs: (type: "search", placeholder: "Search " + site.name, list: "wiki-titles", "aria-label": "Search"))
            html.elem("datalist", attrs: (id: "wiki-titles"))
            html.elem("button", attrs: (type: "submit", title: "Go"), "Go")
          })
        })
      })

      html.elem("main", attrs: (class: if main-page { "mainpage" } else { "article" }), {
        if not main-page {
          html.elem("h1", title)
          html.elem("div", attrs: (class: "tagline"), date-line(created, if me != none { me.updated } else { none }))
        }
        if hatnote != none { html.elem("div", attrs: (class: "hatnote"), hatnote) }

        body

        // 이전 / 다음 문서 (첫 번째 카테고리 안에서)
        if categories.len() > 0 and this-page != none {
          let ps = pages-in(categories.at(0))
          let i = ps.position(p => p.slug == this-page)
          if i != none and ps.len() > 1 {
            html.elem("div", attrs: (class: "prevnext"), {
              html.elem("span", if i > 0 { a(ps.at(i - 1).slug + ".html", "← " + ps.at(i - 1).title) })
              html.elem("span", attrs: (class: "pn-cat"), a(cat-href(categories.at(0)), categories.at(0)))
              html.elem("span", if i + 1 < ps.len() { a(ps.at(i + 1).slug + ".html", ps.at(i + 1).title + " →") })
            })
          }
        }

        if categories.len() > 0 {
          html.elem("div", attrs: (class: "catlinks"), {
            a("categories.html", "Categories")
            ": "
            categories.map(c => a(cat-href(c), c)).join(" | ")
          })
        }
      })

      let edited = if me != none { me.updated } else { datetime.today().display() }
      html.elem("footer", "This page was last edited on " + edited + ". Built with Typst.")
    })
  })
}

// ---------- 페이지 전체: 보고서 모양 (VS Code / Tinymist 미리보기) ----------
#let paged-page(title: "", hatnote: none, categories: (), main-page: false, created: none, body) = {
  set page(paper: "a4", margin: (x: 2.2cm, y: 2.2cm), numbering: "1")
  set text(size: 10.5pt)
  set par(justify: true)
  show heading.where(level: 1): it => block(above: 1.5em, below: 0.8em, width: 100%, {
    text(size: 15pt, weight: "regular", it.body)
    v(-0.5em)
    line(length: 100%, stroke: 0.5pt + luma(160))
  })
  show heading.where(level: 2): set text(size: 11.5pt)
  // 코드: 사이트와 같은 연한 회색 배경
  show raw.where(block: true): it => if it.lang == "mermaid" { it } else {
    block(width: 100%, fill: rgb("#f6f8fa"), stroke: 0.5pt + rgb("#e1e4e8"), inset: 8pt, radius: 2pt, it)
  }
  show link: set text(fill: link-blue)
  show raw.where(block: false): it => box(fill: rgb("#f3f4f6"), inset: (x: 2pt), outset: (y: 2pt), radius: 2pt, it)

  text(size: 22pt, if main-page { site.name } else { title })
  v(-0.6em)
  line(length: 100%, stroke: 0.6pt + luma(160))
  v(-0.3em)
  if not main-page { text(size: 9pt, fill: muted, date-line(created, none)) }
  if hatnote != none { pad(left: 1.5em, text(fill: muted, emph(hatnote))) }

  body

  if categories.len() > 0 {
    v(1.5em)
    block(width: 100%, stroke: 0.5pt + luma(160), fill: luma(248), inset: 6pt,
      text(size: 9pt)[Categories: #categories.join(" | ")])
  }
}

// ---------- 페이지 전체 ----------
#let wiki-page(
  title: "",
  hatnote: none,
  categories: (),
  main-page: false,   // true 면 메인 포털 (제목/카테고리 줄 숨김)
  order: none,        // 카테고리 안에서의 순서 (1, 2, 3...). 없으면 제목 가나다순
  created: none,      // 처음 쓴 날 "2026-11-08" (제목 밑에 표시)
  body,
) = {
  set document(title: if main-page { site.name } else { title + " — " + site.name })

  // build.sh 가 읽어 가는 문서 정보
  [#metadata((title: title, categories: categories, order: order)) <wiki-meta>]

  show raw.where(lang: "mermaid"): it => draw(mermaid-block(it))

  let args = (title: title, hatnote: hatnote, categories: categories, main-page: main-page, created: created)
  context if is-html() { html-page(..args, body) } else { paged-page(..args, body) }
}
