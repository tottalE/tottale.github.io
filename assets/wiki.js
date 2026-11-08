// 검색창 + 랜덤 문서. 문서 목록은 각 페이지에 들어 있는 window.WIKI_INDEX 를 써요.
(function () {
  var pages = window.WIKI_INDEX || [];
  var go = function (slug) { location.href = slug + ".html"; };

  // 랜덤 문서 (메인 페이지는 제외)
  document.querySelectorAll(".random-page").forEach(function (el) {
    el.addEventListener("click", function (e) {
      e.preventDefault();
      var pool = pages.filter(function (p) { return p.slug !== "index"; });
      if (pool.length) go(pool[Math.floor(Math.random() * pool.length)].slug);
    });
  });

  // 사이드바 소제목 목차: 지금 읽고 있는 부분을 강조
  var tocLinks = document.querySelectorAll(".tree .subtoc a");
  if (tocLinks.length && "IntersectionObserver" in window) {
    var byId = {};   // 같은 문서가 두 카테고리에 있으면 링크가 2개라서 배열로
    tocLinks.forEach(function (a) {
      var id = decodeURIComponent(a.getAttribute("href").slice(1));
      (byId[id] = byId[id] || []).push(a);
    });
    var heads = Array.prototype.filter.call(document.querySelectorAll("main h2[id]"), function (h) { return byId[h.id]; });
    var setActive = function () {
      var current = heads[0];
      var atBottom = window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 4;
      heads.forEach(function (h) {
        var top = h.getBoundingClientRect().top;
        // 페이지 끝까지 내렸으면 화면에 보이는 마지막 소제목, 아니면 화면 위쪽을 지난 마지막 소제목
        if (top < 120 || (atBottom && top < window.innerHeight)) current = h;
      });
      tocLinks.forEach(function (a) { a.classList.remove("active"); });
      if (current) byId[current.id].forEach(function (a) { a.classList.add("active"); });
    };
    window.addEventListener("scroll", setActive, { passive: true });
    setActive();
  }

  // 검색: 제목 자동완성, Enter → 제목이 같은 문서, 없으면 제목에 포함된 첫 문서
  var form = document.querySelector("form.search");
  if (!form) return;
  var input = form.querySelector("input");
  var list = form.querySelector("datalist");
  pages.forEach(function (p) {
    var o = document.createElement("option");
    o.value = p.title;
    list.appendChild(o);
  });
  form.addEventListener("submit", function (e) {
    e.preventDefault();
    var q = input.value.trim().toLowerCase();
    if (!q) return;
    var hit = pages.find(function (p) { return p.title.toLowerCase() === q || p.slug === q; })
           || pages.find(function (p) { return p.title.toLowerCase().indexOf(q) !== -1; });
    if (hit) go(hit.slug);
    else { input.value = ""; input.placeholder = "No page called “" + q + "”"; }
  });
})();
