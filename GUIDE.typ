// JinjuWiki — how to use it (easy English guide)
// Open this file in VS Code and press the preview button, or read GUIDE.pdf.
#import "lib/wiki.typ": tip, info, warning, caution, important

#set document(title: "JinjuWiki — How to use it")
#set page(paper: "a4", margin: (x: 2cm, y: 2cm), numbering: "1")
#set text(size: 10.5pt)
#set par(justify: false)
#set heading(numbering: "1.")
#show heading.where(level: 1): it => block(above: 1.6em, below: 0.8em, width: 100%, {
  text(size: 15pt, weight: "bold", it)
  v(-0.5em)
  line(length: 100%, stroke: 0.5pt + luma(170))
})
#show raw.where(block: true): it => block(width: 100%, fill: rgb("#f6f8fa"), stroke: 0.5pt + rgb("#e1e4e8"), inset: 8pt, radius: 2pt, it)
#show raw.where(block: false): it => box(fill: rgb("#f3f4f6"), inset: (x: 2pt), outset: (y: 2pt), radius: 2pt, it)

// small diagram helpers (boxes + arrows)
#let bx(body, fill: rgb("#f6f8fa")) = box(stroke: 0.7pt + luma(110), radius: 4pt, inset: (x: 8pt, y: 6pt), fill: fill,
  align(center, text(size: 9pt, body)))
#let arr(label) = align(center, {
  if label != none { text(size: 7.5pt, fill: luma(80), label); linebreak() }
  text(size: 13pt, fill: luma(80), sym.arrow.r)
})
#let flow(..items) = align(center, grid(columns: items.pos().len(), align: horizon + center, column-gutter: 4pt, ..items))

// table style used in this guide
#let t(columns: 2, ..cells) = table(
  columns: columns, stroke: 0.5pt + luma(180), inset: 6pt,
  fill: (_, y) => if y == 0 { luma(235) },
  ..cells.pos().enumerate().map(((i, c)) => if i < columns { strong(c) } else { c }),
)

#align(center)[
  #text(size: 24pt)[JinjuWiki]
  #v(-0.6em)
  #text(size: 12pt, fill: luma(90))[How to use it — the short guide]
]

#v(0.5em)
#info(title: "In one sentence")[
  You write *one `.typ` file per wiki page*. VS Code shows it as a *report*.
  `bash build.sh` turns all pages into a *website*.
]

= The big picture

The same file is used in two ways:

#flow(
  bx[`pages/uart.typ` \ _you write here_],
  arr[you type],
  bx(fill: rgb("#eef6ee"))[*VS Code preview* \ report style],
)
#flow(
  bx[`pages/uart.typ`],
  arr[`bash build.sh`],
  bx(fill: rgb("#eef3fb"))[*`public/uart.html`* \ wiki style],
  arr[later: `git push`],
  bx[`jinjuok.is-a.dev`],
)

#t(columns: 3,
  [], [Preview (VS Code)], [Website (build.sh)],
  [Looks like], [A4 report], [Wikipedia-style site],
  [Updates], [Every key you type], [When you run `bash build.sh`],
  [Use it for], [Writing], [Checking the final look],
)

#tip[Write with the preview. Build the site only when you want to see the real wiki.]

= Which file do I touch?

#t(columns: 3,
  [File / folder], [What it is], [Do I edit it?],
  [`pages/*.typ`], [The wiki pages. *1 file = 1 page.* File name = page address.], [*Yes, all the time*],
  [`pages/_new-page.typ.template`], [Empty page to copy], [Copy it, don't edit],
  [`site.typ`], [Site name, menu, main-page categories], [Sometimes],
  [`lib/wiki.typ`], [The template (all the magic)], [No — ask Claude],
  [`assets/`], [Design (CSS), logo, pictures], [Only to add pictures],
  [`build.sh`], [Builds the website], [No],
  [`public/`, `build/`], [Made by `build.sh`. Deleted every build.], [*Never*],
)

= Every day: write a page

+ Open the folder `typst-wiki` in *VS Code*.
+ Open a page, for example `pages/uart.typ`.
+ Click the *preview* icon (top right), or `Cmd+Shift+P` → `Typst Preview`.
+ Write. The preview changes while you type.
+ Want to see the real website? In the terminal:

```bash
bash build.sh                                   # build all pages
python3 -m http.server 8000 --directory public  # start preview server (once)
```

Then open `http://localhost:8000` and press `Cmd+Shift+R` after each build.

= Make a new page

#flow(
  bx[Copy \ `_new-page.typ.template`], arr(none),
  bx[Save as \ `pages/spi.typ`], arr(none),
  bx[Set `title` + \ `categories`], arr(none),
  bx[Link to it: \ `#wlink("spi")`],
)

+ Copy `pages/_new-page.typ.template` → save as `pages/spi.typ`.
+ At the top, set the title and the category:

```typ
#import "../lib/wiki.typ": *

#show: wiki-page.with(
  title: "SPI",
  categories: ("Peripherals",),   // which box on the main page
  // order: 3,                    // optional: position in the category
)

*SPI* is a fast serial bus ...
```

3. From any other page, link to it with `#wlink("spi")[SPI]`.

#info[The file name is the address: `pages/spi.typ` → `spi.html` → `#wlink("spi")`.]

= Writing cheat sheet

Normal Typst works as usual: `*bold*`, `_italic_`, `- list`, `+ numbered list`, `$x^2$` math, and code blocks with three backticks.
These are the *wiki extras*:

#t(columns: 2,
  [What you want], [What you type],
  [Section / sub-section], [`= Title`  #h(1em) `== Sub-title`],
  [Link to another wiki page], [`#wlink("uart")[UART]`],
  [Link to a website], [`#link("https://st.com")[ST]`],
  [Source / footnote], [`text.#note[RM0090, p. 120]` and at the end `= References` + `#references()`],
  [Table of contents], [`#toc()` (after the first paragraph)],
  [Info box on the right], [`#infobox(title: "STM32", ("Core", [Cortex-M4]), section("Memory"), ("Flash", [1 MB]))`],
  [Table], [`#wikitable(columns: 2, [Pin], [Use], [PA9], [TX])` — first row = header],
  [Note boxes], [`#tip[...]` `#info[...]` `#important[...]` `#warning[...]` `#caution[...]`],
  [Box with own title / no title], [`#warning(title: "Pitfall")[...]` / `#tip(title: none)[...]`],
  [Diagram (Mermaid)], [A code block with language `mermaid` (see below)],
  [Picture], [Put `pic.png` in `assets/`, then `#image("/assets/pic.png")`],
)

== Note boxes look like this

#tip[Enable the GPIO clock in `RCC` first.]
#warning(title: "Pitfall")[Forgot `volatile` → the optimizer removes the loop.]

== Diagrams

*Mermaid* — just write a code block. It works in the preview *and* on the website.

````typ
```mermaid
flowchart LR
  MCU -->|I2C| Sensor
```
````

*Other diagram packages* (timing, registers, circuits) — wrap them in `#draw(...)`:

```typ
#import "@preview/wavy:0.1.3"        // at the top of the page

#draw(wavy.render(`{signal: [{name: "TX", wave: "1.0==1", data: ["D0","D1"]}]}`.text))
```

#t(columns: 3,
  [Package], [Draws], [Import line],
  [wavy], [Timing diagrams (WaveDrom)], [`#import "@preview/wavy:0.1.3"`],
  [bytefield], [Register bits], [`#import "@preview/bytefield:0.0.9": *`],
  [zap], [Circuits], [`#import "@preview/zap:0.6.0"`],
  [fletcher], [Block diagrams], [`#import "@preview/fletcher:0.5.8"`],
)

#info[A package is downloaded *once* per computer, the first time you use it. After that it works offline.]

= Categories and the main page

You only write `categories:` at the top of a page. The rest happens automatically:

#flow(
  bx[`categories: ("Peripherals",)`],
  arr(none),
  stack(dir: ttb, spacing: 4pt,
    bx[Box on the main page],
    bx[Sidebar tree (opens on this page)],
    bx[`category-peripherals.html`],
    bx[← Prev / Next → links at the bottom],
  ),
)

#t(columns: 2,
  [I want to...], [Do this],
  [Add a box to the main page], [Add a line to `portal:` in `site.typ`],
  [Change the order inside a category], [Add `order: 1`, `order: 2`, ... to each page],
  [Change site name / slogan], [`name:` and `tagline:` in `site.typ`],
  [Change the logo], [Edit `tools/pixel-logo.py`, then run `python3 tools/pixel-logo.py`],
)

#info[In the *preview*, the main-page boxes and "Recent changes" are empty. They are filled only when you run `build.sh`. This is normal.]

= Watch out

#warning(title: "Disappears on the website")[
  `#align(...)`, `#grid(...)`, `#rect`, `#line`, `#v(...)`, text colour.
  They show in the preview, but the website drops them.
  → Put them inside `#draw(...)`, or ask Claude for a helper.
]

#warning(title: "Don't use html.elem in pages")[
  It breaks the preview. Use the helpers in the cheat sheet instead.
]

#caution(title: "#note is not a note box")[
  `#note[...]` makes a *footnote / source*. For a note box use `#info[...]`.
]

#t(columns: 2,
  [You see...], [It means...],
  [A *red* link on the website], [That page does not exist yet. Create `pages/<name>.typ`.],
  [`warning: html export is under active development`], [Normal. Ignore it.],
  [`warning: ... was ignored during HTML export`], [Something will be missing on the website (see above).],
  [`error: ... would escape the project root`], [Run commands from the `typst-wiki` folder.],
  [Website doesn't change], [Did you run `bash build.sh`? Then `Cmd+Shift+R`.],
)

= Putting it online (later)

+ Create a GitHub repository and push this folder.
+ GitHub → *Settings → Pages → Source: GitHub Actions*.
+ Every `git push` builds and publishes the site automatically.
+ When the pages have real content, apply for `jinjuok.is-a.dev` *yourself* (the is-a.dev rules forbid AI-written requests).

#important[Fill in a few pages with real notes first — is-a.dev rejects empty sites.]
