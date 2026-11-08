# JinjuWiki — Typst로 만든 개인 위키

> 쉬운 영어 사용 설명서: `GUIDE.typ` (PDF: `GUIDE.pdf`)

문서 하나 = `pages/` 안의 `.typ` 파일 하나. 문서끼리 링크로 이어져요.

```
site.typ            사이트 이름, 사이드바 메뉴, 링크
lib/wiki.typ        위키 템플릿 (인포박스, 목차, 각주, 위키 링크)
pages/*.typ         문서들 (index.typ = 메인 포털, user-jinju.typ = 프로필)
assets/wiki.css     위키 스타일 (사진도 여기에)
build.sh            전체 빌드 → public/
.github/workflows/  push 하면 자동 빌드 + GitHub Pages 배포
```

## 카테고리 (메인 페이지 박스)

문서 맨 위 `categories: ("STM32",)` 에 카테고리 이름을 쓰면, 빌드할 때 메인 페이지의 그 박스와
`category-stm32.html` 페이지에 자동으로 들어가요. 메인에 보일 박스 목록은 `site.typ` 의 `portal` 에서 바꿔요.

## 위키 링크

```typst
#wlink("stm32")[STM32]
```
누르면 `pages/stm32.typ` 문서로 이동. 그 파일이 아직 없으면 위키백과처럼 **빨간 링크**로 보여요.
새 문서는 `pages/_new-page.typ.template`을 복사해서 `pages/이름.typ`로 저장하면 돼요.

## 그 외 기능

| 쓰는 법 | 기능 |
|---|---|
| `#infobox(title: ..., ("항목", [값]), section("제목"))` | 오른쪽 정보 박스 |
| `#toc()` | 목차 (도입부 다음에) |
| `#note[출처]` + 맨 아래 `#references()` | 각주 |
| `= 제목`, `== 소제목` | 섹션 |

## GitHub Pages 배포 (처음 한 번)

1. GitHub에 `tottale.github.io` 저장소를 만들고 이 폴더 전체를 push
2. 저장소 **Settings → Pages → Source**를 **GitHub Actions**로 변경
3. 이후 `main`에 push할 때마다 자동으로 빌드되고 `https://tottale.github.io`에 올라가요
4. `site.typ`와 문서 안의 `tottale`을 본인 아이디로 바꾸기

## 내 컴퓨터에서 미리보기

```bash
bash build.sh
python3 -m http.server 8000 --directory public
# → http://localhost:8000
```
Typst HTML export는 아직 실험 기능이라 `--features html` 옵션이 필요해요 (build.sh에 이미 들어 있음).
