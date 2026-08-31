import { defineConfig } from "vite";

function normalizeDocumentationHtml(html) {
  const jqueryPattern = /\s*<script\b[^>]*src="_static\/js\/jquery-3\.7\.1\.min\.js"[^>]*><\/script>\s*/;
  const jqueryScript = html.match(jqueryPattern)?.[0].replace(/\s+integrity="[^"]*"/, "").trim();

  let normalizedHtml = html
    .replace(/\s+integrity="[^"]*"/g, "")
    .replace(/\s*<script src="\.\/"[^>]*><\/script>\s*/g, "\n");

  if (jqueryScript) {
    normalizedHtml = normalizedHtml
      .replace(jqueryPattern, "\n")
      .replace(
        /(<script\b[^>]*src="_static\/js\/bootstrap3\.min\.js"[^>]*><\/script>)/,
        `${jqueryScript}\n$1`,
      );
  }

  if (
    normalizedHtml.includes('src="searchindex.js"') &&
    !normalizedHtml.includes('src="_static/searchtools.js"')
  ) {
    normalizedHtml = normalizedHtml.replace(
      /(<script\b[^>]*src="searchindex\.js"[^>]*><\/script>)/,
      '<script src="_static/searchtools.js"></script>\n    <script src="_static/language_data.js"></script>\n    $1',
    );
  }

  return normalizedHtml;
}

export default defineConfig({
  root: "docs/_build/html",
  plugins: [
    {
      name: "normalize-generated-documentation-html",
      transformIndexHtml: normalizeDocumentationHtml,
    },
  ],
});