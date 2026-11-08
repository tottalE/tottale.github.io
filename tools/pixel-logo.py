# 도트 로고 만들기: 아래 그림(24x24)을 고치고 `python3 tools/pixel-logo.py` 실행 → assets/logo.svg
# 글자 하나 = 한 칸.
ART = """
.....G...G....G...G.....
.....G...G....G...G.....
..KKKKKKKKKKKKKKKKKKKK..
..KDDDDDDDDDDDDDDDDDDK..
..KDdDDDDDDDDDDDDDDDDK..
GGKDDDDDDDDDDDDDDDDDDKGG
..KDDBBBBBBBBBBBBBDDDK..
..KDBFFFFFFFFFFFFFBDSK..
..KBFFFBBFFBFFBFBFFBSK..
GGKBFFBFFBFBFBFFBFFBSKGG
..KBFFBFFBFBBFFFBFFBSK..
..KBFFBFFBFBFBFFFFFBSK..
..KBFFFBBFFBFFBFBFFBSK..
..KDBFFFFFFFFFFFFFBDSK..
GGKDDBBBFFBBBBBBBBDDSKGG
..KDSSSBFBSSSSSSSSSSSK..
..KDDDBFBSSDDDDDDDDDDK..
..KDDBBBSSDDDDDDDDDDDK..
GGKDDDSSSDDDDDDDDDDDDKGG
..KDDDDDDDDDDDDDDDDDDK..
..KDDDDDDDDDDDDDDDDDDK..
..KKKKKKKKKKKKKKKKKKKK..
.....G...G....G...G.....
.....G...G....G...G.....
"""
COLORS = {
    "G": "#9da3ab",  # 칩 핀
    "K": "#1b1d22",  # 칩 테두리
    "D": "#3a3e47",  # 칩 몸통
    "d": "#70767f",  # 1번 핀 표시 점
    "B": "#111111",  # 말풍선 선 / 글자
    "F": "#ffffff",  # 말풍선 안
    "S": "#8a8f98",  # 말풍선 그림자
}
rows = ART.strip().splitlines()
rects = []
for y, row in enumerate(rows):
    for x, ch in enumerate(row):
        if ch in COLORS:
            rects.append(f'<rect x="{x}" y="{y}" width="1" height="1" fill="{COLORS[ch]}"/>')
w, h = len(rows[0]), len(rows)
svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" shape-rendering="crispEdges" '
       'role="img" aria-label="JinjuWiki logo">\n' + "\n".join(rects) + "\n</svg>\n")
open("assets/logo.svg", "w").write(svg)
print("wrote assets/logo.svg")
