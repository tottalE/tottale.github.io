#!/usr/bin/env bash
# 위키 전체를 HTML 로 빌드해서 public/ 에 넣어요.
#  0) 문서 목록 만들기 (파일 이름 → 주소)
#  1) 각 문서의 제목/카테고리를 모아 build/index.json 생성
#  2) 문서 빌드
#  3) 카테고리 페이지 자동 생성
set -euo pipefail
# (typst eval 은 0.15 이상 필요)
cd "$(dirname "$0")"

rm -rf public build
mkdir -p public build/meta
cp -r assets/. public/

TC=(typst compile --root . --features html --format html)
EV=(typst eval --root . --features html --target html --input index=/build/index.json)

# 0) 문서 목록: slug <TAB> 종류 <TAB> 파일
python3 - <<'EOF'
import os, re, sys
def slug(s): return re.sub(r"[\W_]+", "-", s.lower().strip()).strip("-")
rows = []
for f in sorted(os.listdir("pages")):
    if f.endswith(".typ"):
        rows.append((f[:-4], "typ", f"pages/{f}"))
seen = {}
for s, k, p in rows:
    if s in seen:
        sys.exit(f"error: '{p}' and '{seen[s]}' both become '{s}.html' — rename one of them")
    seen[s] = p
with open("build/manifest.tsv", "w") as out:
    for r in rows: out.write("\t".join(r) + "\n")
EOF
PAGES=$(cut -f1 build/manifest.tsv | paste -sd, -)

# 1) 문서 정보 모으기
echo '[]' > build/index.json
while IFS=$'\t' read -r slug kind file; do
  "${EV[@]}" 'query(<wiki-meta>).first().value' --in "$file" > "build/meta/$slug.json" 2>/dev/null \
    || { echo "error reading $file"; "${EV[@]}" 'query(<wiki-meta>).first().value' --in "$file" >/dev/null; }
done < build/manifest.tsv

# 수정 날짜: git 기록이 있으면 마지막 커밋 날짜, 없으면 파일 수정 시각
python3 - <<'EOF'
import json, os, subprocess, datetime
out = []
for line in open("build/manifest.tsv"):
    slug, kind, src = line.rstrip("\n").split("\t")
    meta = json.load(open(f"build/meta/{slug}.json"))
    date = ""
    try:
        r = subprocess.run(["git", "status", "--porcelain", "--", src], capture_output=True, text=True).stdout.strip()
        if not r:  # 커밋된 그대로면 커밋 날짜
            date = subprocess.run(["git", "log", "-1", "--format=%cd", "--date=short", "--", src],
                                  capture_output=True, text=True).stdout.strip()
    except FileNotFoundError:
        pass
    if not date:
        date = datetime.date.fromtimestamp(os.path.getmtime(src)).isoformat()
    out.append({"slug": slug, "title": meta["title"], "categories": meta["categories"], "order": meta.get("order"), "updated": date})
json.dump(out, open("build/index.json", "w"), ensure_ascii=False, indent=1)
EOF

# 2) 문서 빌드
while IFS=$'\t' read -r slug kind file; do
  echo "building $slug  ($file)"
  "${TC[@]}" --input "pages=$PAGES" --input index=/build/index.json --input "page=$slug" \
    "$file" "public/$slug.html"
done < build/manifest.tsv

# 3) 카테고리 페이지
"${EV[@]}" 'query(<all-cats>).first().value' --in lib/category.typ 2>/dev/null \
  | python3 -c 'import json,sys; print("\n".join(json.load(sys.stdin)))' > build/categories.txt
"${TC[@]}" --input index=/build/index.json lib/category.typ public/categories.html
while IFS= read -r cat; do
  [ -z "$cat" ] && continue
  file=$(python3 -c 'import re,sys; print("category-"+re.sub(r"[\W_]+","-",sys.argv[1].lower().strip()).strip("-"))' "$cat")
  echo "building $file"
  "${TC[@]}" --input index=/build/index.json --input "cat=$cat" lib/category.typ "public/$file.html"
done < build/categories.txt

echo "done → public/index.html"
