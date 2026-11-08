#!/usr/bin/env bash
# pages/*.typ 를 전부 HTML 로 빌드해서 public/ 에 넣어요.
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
NAMES=$(ls pages/*.typ | xargs -n1 basename | sed 's/\.typ$//')
PAGES=$(echo "$NAMES" | paste -sd, -)

# 1) 문서 정보 모으기
echo '[]' > build/index.json
for name in $NAMES; do
  typst eval --root . --features html --target html --input index=/build/index.json \
    'query(<wiki-meta>).first().value' --in "pages/$name.typ" > "build/meta/$name.json" 2>/dev/null
done

# 수정 날짜: git 기록이 있으면 마지막 커밋 날짜, 없으면 파일 수정 시각
python3 - <<'EOF'
import json, os, subprocess, datetime
out = []
for f in sorted(os.listdir("build/meta")):
    name = f[:-5]
    meta = json.load(open(f"build/meta/{f}"))
    src = f"pages/{name}.typ"
    date = ""
    try:
        date = subprocess.run(["git", "log", "-1", "--format=%cd", "--date=short", "--", src],
                              capture_output=True, text=True).stdout.strip()
    except FileNotFoundError:
        pass
    if not date:
        date = datetime.date.fromtimestamp(os.path.getmtime(src)).isoformat()
    out.append({"slug": name, "title": meta["title"], "categories": meta["categories"], "order": meta.get("order"), "updated": date})
json.dump(out, open("build/index.json", "w"), ensure_ascii=False, indent=1)
EOF

# 2) 문서 빌드
for name in $NAMES; do
  echo "building $name"
  "${TC[@]}" --input "pages=$PAGES" --input index=/build/index.json --input "page=$name" \
    "pages/$name.typ" "public/$name.html"
done

# 3) 카테고리 페이지
typst eval --root . --features html --target html --input index=/build/index.json \
  'query(<all-cats>).first().value' --in lib/category.typ 2>/dev/null \
  | python3 -c 'import json,sys; print("\n".join(json.load(sys.stdin)))' > build/categories.txt
"${TC[@]}" --input index=/build/index.json lib/category.typ public/categories.html
while IFS= read -r cat; do
  [ -z "$cat" ] && continue
  file=$(python3 -c 'import re,sys; print("category-"+re.sub(r"[^\w]+","-",sys.argv[1].lower(),flags=re.U).strip("-"))' "$cat")
  echo "building $file"
  "${TC[@]}" --input index=/build/index.json --input "cat=$cat" lib/category.typ "public/$file.html"
done < build/categories.txt

echo "done → public/index.html"
