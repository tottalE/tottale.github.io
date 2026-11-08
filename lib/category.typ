// 카테고리 페이지 — build.sh 가 카테고리마다 자동으로 만들어요. 직접 고칠 필요 없음.
//   --input cat=STM32  → Category:STM32 페이지
//   cat 없음           → 모든 카테고리 목록 (categories.html)
#import "wiki.typ": *

#let cat = sys.inputs.at("cat", default: none)
// 문서에 쓰인 카테고리 + 메인 포털의 카테고리 (문서가 아직 없어도 페이지는 생김)
#let all-cats = (wiki-index.map(p => p.categories).flatten() + site.portal.map(x => x.at(0))).dedup().sorted(key: lower)
#metadata(all-cats) <all-cats>

#show: wiki-page.with(title: if cat == none { "Special:Categories" } else { "Category:" + cat })

#if cat == none [
  This wiki has #all-cats.len() categories.

  #html.elem("ul", for c in all-cats {
    html.elem("li", [#a(cat-href(c), c) (#pages-in(c).len())])
  })
] else [
  #let ps = pages-in(cat)
  #let desc = site.portal.find(x => x.at(0) == cat)
  #if desc != none { html.elem("p", desc.at(1)) }

  == Pages in category "#cat"
  The following #ps.len() #if ps.len() == 1 [page is] else [pages are] in this category.

  #html.elem("ul", attrs: (class: "catlist"), for p in ps { html.elem("li", page-link(p)) })
]
