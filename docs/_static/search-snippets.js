"use strict";

(function () {
  function escapeRegExp(value) {
    return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  function allMatchRanges(text, keywords) {
    var ranges = [];
    keywords.forEach(function (keyword) {
      if (!keyword) return;
      var matcher = new RegExp(escapeRegExp(keyword), "gi");
      var match;
      while ((match = matcher.exec(text)) !== null) {
        ranges.push({
          start: Math.max(0, match.index - 120),
          end: Math.min(text.length, match.index + match[0].length + 120)
        });
        if (match[0].length === 0) matcher.lastIndex += 1;
      }
    });
    return ranges.sort(function (left, right) {
      return left.start - right.start;
    });
  }

  function mergeRanges(ranges) {
    return ranges.reduce(function (merged, range) {
      var previous = merged[merged.length - 1];
      if (previous && range.start <= previous.end) {
        previous.end = Math.max(previous.end, range.end);
      } else {
        merged.push({start: range.start, end: range.end});
      }
      return merged;
    }, []);
  }

  function makeSearchSummary(htmlText, keywords, anchor) {
    var text = Search.htmlToText(htmlText, anchor);
    if (!text) return null;

    var ranges = mergeRanges(allMatchRanges(text, keywords));
    if (!ranges.length) return null;

    var container = document.createElement("div");
    container.classList.add("search-snippets");
    ranges.forEach(function (range) {
      var snippet = document.createElement("p");
      snippet.classList.add("context");
      snippet.textContent =
        (range.start > 0 ? "..." : "") +
        text.substring(range.start, range.end).trim() +
        (range.end < text.length ? "..." : "");
      container.appendChild(snippet);
    });
    return container;
  }

  Search.makeSearchSummary = makeSearchSummary;
}());
