"""Build Signals API pages without generating dependency documentation."""

import hashlib
import html
import json
import os
import pathlib
import posixpath
import re
import shutil
import subprocess
import sys
import time
import urllib.parse


SIGNALS_ROOT = pathlib.Path(__file__).resolve().parent
PROJECT_ROOT = SIGNALS_ROOT.parents[1]
BUILD_DIR = SIGNALS_ROOT / ".lake" / "build"
DATABASE = BUILD_DIR / "api-docs-signals.db"
DOC_DIR = BUILD_DIR / "doc"
MANIFEST = BUILD_DIR / "doc-manifest.json"
CACHE_MANIFEST = BUILD_DIR / "api-docs-cache.json"
BLUEPRINT_DIR = BUILD_DIR / "blueprint"
DOCGEN = SIGNALS_ROOT / ".lake" / "packages" / "doc-gen4" / ".lake" / "build" / "bin" / "doc-gen4"
DOCGEN_BATCH = BUILD_DIR / "bin" / "signalsApiDocs"

HOSTED_DOCS = {
    "Mathlib": "https://leanprover-community.github.io/mathlib4_docs/",
    "Physlib": "https://physlib.io/docs/",
    "Init": "https://lean-lang.org/doc/api/",
    "Std": "https://lean-lang.org/doc/api/",
    "Lake": "https://lean-lang.org/doc/api/",
    "Lean": "https://lean-lang.org/doc/api/",
}
HREF_ATTRIBUTE = re.compile(r'(?P<prefix>\bhref\s*=\s*)(?P<quote>["\'])(?P<url>.*?)(?P=quote)', re.IGNORECASE)
BEGIN_ENV_TITLE = re.compile(r"^(\\begin\{[^}]+\}\[)(.*)(\]\s*)$")
ALIGNMENT_ENV_NAMES = (
    r"(?:[a-zA-Z]*matrix|cases|dcases|rcases|aligned|alignedat|align\*?|array|tabular|split| subarray)"
)
ALIGNMENT_SPAN = re.compile(
    rf"\\begin\{{{ALIGNMENT_ENV_NAMES}\}}.*?\\end\{{{ALIGNMENT_ENV_NAMES}\}}"
)
ALIGNMENT_BEGIN = re.compile(rf"\\begin\{{{ALIGNMENT_ENV_NAMES}\}}")
ALIGNMENT_END = re.compile(rf"\\end\{{{ALIGNMENT_ENV_NAMES}\}}")
UNESCAPED_PERCENT = re.compile(r"(?<!\\)%")
UNESCAPED_AMPERSAND = re.compile(r"(?<!\\)&")
UNESCAPED_DOLLAR = re.compile(r"(?<!\\)\$")
CURRENCY_DOLLAR = re.compile(r"(?<!\\)\$(?=\d[\d,.]*(?:[kKmMbB]\b|\s|/|\)|\]|,|\.|;|:|$))")
DOCGEN_PROFILE = os.environ.get("SIGNALS_DOCGEN_PROFILE") == "1"
DOCGEN_DEBUG = os.environ.get("SIGNALS_DOCGEN_DEBUG") == "1"
FORCE_REBUILD = os.environ.get("SIGNALS_API_FORCE_REBUILD") == "1"


def github_web_url(remote: str) -> str:
    if remote.startswith("ssh://git@github.com/"):
        remote = "https://github.com/" + remote.removeprefix("ssh://git@github.com/")
    elif remote.startswith("git@github.com:"):
        remote = "https://github.com/" + remote.removeprefix("git@github.com:")
    return remote.removesuffix(".git").rstrip("/")


def rewrite_module_href(
    href: str,
    page_path: str,
    architect_source_base: str,
    local_doc_dir: pathlib.Path | None = None,
) -> str:
    parsed = urllib.parse.urlsplit(html.unescape(href))
    if parsed.scheme or parsed.netloc or not parsed.path:
        return href

    target_path = posixpath.normpath(
        posixpath.join(posixpath.dirname(page_path), parsed.path)
    )
    target_module_path = target_path.removesuffix(".html")
    path_parts = pathlib.PurePosixPath(target_module_path).parts
    if not path_parts:
        return href

    module_root = path_parts[0]
    if module_root == "Architect":
        source_path = target_module_path + ".lean"
        return architect_source_base + source_path

    hosted_base = HOSTED_DOCS.get(module_root)
    if hosted_base is None:
        return href
    target = pathlib.PurePosixPath(target_path)
    if (
        local_doc_dir is not None
        and not target.is_absolute()
        and ".." not in target.parts
        and local_doc_dir.joinpath(*target.parts).is_file()
    ):
        return href
    return f"{hosted_base}{target_path}{('?'+parsed.query) if parsed.query else ''}{('#'+parsed.fragment) if parsed.fragment else ''}"


def rewrite_html_links(doc_dir: pathlib.Path, architect_source_base: str) -> None:
    for html_path in doc_dir.rglob("*.html"):
        page_path = html_path.relative_to(doc_dir).as_posix()
        content = html_path.read_text(encoding="utf-8")

        def replace_href(match: re.Match[str], page_path: str = page_path) -> str:
            old_href = html.unescape(match.group("url"))
            new_href = rewrite_module_href(
                old_href, page_path, architect_source_base, local_doc_dir=doc_dir
            )
            if new_href == old_href:
                return match.group(0)
            return (
                match.group("prefix")
                + match.group("quote")
                + html.escape(new_href, quote=True)
                + match.group("quote")
            )

        new_content = HREF_ATTRIBUTE.sub(replace_href, content)
        if new_content != content:
            html_path.write_text(new_content, encoding="utf-8")


def sanitize_blueprint_tex_text(text: str) -> str:
    """Escape raw %, &, and currency $ inside generated LeanArchitect .tex artifacts.

    Preserves column-alignment `&` inside single-line and multi-line LaTeX alignment
    environments (`*matrix`, `cases`, `aligned`, `align`, `array`, `tabular`, `split`).
    """
    lines = text.splitlines(keepends=True)
    non_comment_text = "".join(line for line in lines if not line.lstrip().startswith("%"))
    has_odd_total_dollars = len(UNESCAPED_DOLLAR.findall(non_comment_text)) % 2 == 1
    out: list[str] = []
    align_depth = 0
    for idx, line in enumerate(lines):
        if line.lstrip().startswith("%"):
            out.append(line)
            continue
        fixed = UNESCAPED_PERCENT.sub(r"\%", line)
        if has_odd_total_dollars and len(UNESCAPED_DOLLAR.findall(fixed)) % 2 == 1:
            fixed = CURRENCY_DOLLAR.sub(r"\$", fixed)

        if align_depth > 0:
            # Currently inside a multi-line alignment environment: preserve `&` up to matching `\end{...}`
            end_match = ALIGNMENT_END.search(fixed)
            if end_match and len(ALIGNMENT_END.findall(fixed)) > len(ALIGNMENT_BEGIN.findall(fixed)):
                # Escape `&` only after the closing alignment environment if depth returns to 0
                new_depth = align_depth + len(ALIGNMENT_BEGIN.findall(fixed)) - len(ALIGNMENT_END.findall(fixed))
                if new_depth <= 0:
                    last_end = list(ALIGNMENT_END.finditer(fixed))[-1].end()
                    fixed = fixed[:last_end] + UNESCAPED_AMPERSAND.sub(r"\&", fixed[last_end:])
                    align_depth = 0
                else:
                    align_depth = new_depth
            else:
                align_depth = max(
                    0,
                    align_depth + len(ALIGNMENT_BEGIN.findall(fixed)) - len(ALIGNMENT_END.findall(fixed)),
                )
        elif ALIGNMENT_BEGIN.search(fixed):
            if ALIGNMENT_SPAN.search(fixed):
                parts: list[str] = []
                last = 0
                for match in ALIGNMENT_SPAN.finditer(fixed):
                    parts.append(UNESCAPED_AMPERSAND.sub(r"\&", fixed[last:match.start()]))
                    parts.append(match.group(0))
                    last = match.end()
                tail = fixed[last:]
                unclosed_begin = ALIGNMENT_BEGIN.search(tail)
                if unclosed_begin:
                    parts.append(UNESCAPED_AMPERSAND.sub(r"\&", tail[:unclosed_begin.start()]))
                    parts.append(tail[unclosed_begin.start():])
                    align_depth = len(ALIGNMENT_BEGIN.findall(tail)) - len(ALIGNMENT_END.findall(tail))
                else:
                    parts.append(UNESCAPED_AMPERSAND.sub(r"\&", tail))
                fixed = "".join(parts)
            else:
                first_begin = ALIGNMENT_BEGIN.search(fixed)
                assert first_begin is not None
                fixed = (
                    UNESCAPED_AMPERSAND.sub(r"\&", fixed[:first_begin.start()])
                    + fixed[first_begin.start():]
                )
                align_depth = max(
                    0,
                    len(ALIGNMENT_BEGIN.findall(fixed)) - len(ALIGNMENT_END.findall(fixed)),
                )
        else:
            fixed = UNESCAPED_AMPERSAND.sub(r"\&", fixed)

        if idx == 0:
            m = BEGIN_ENV_TITLE.match(fixed)
            if m:
                prefix, inner, suffix = m.groups()
                if inner.startswith("{") and inner.endswith("}"):
                    inner = inner[1:-1]
                if "[" in inner or "]" in inner:
                    inner = inner.replace("[", r"$\lbrack$").replace("]", r"$\rbrack$")
                    fixed = f"{prefix}{inner}{suffix}"
        out.append(fixed)
    return "".join(out)


def sanitize_blueprint_tex(blueprint_dir: pathlib.Path = BLUEPRINT_DIR) -> int:
    """Sanitize generated .artifacts/*.tex files in-place before plasTeX runs."""
    if not blueprint_dir.is_dir():
        return 0
    modified = 0
    for tex_path in sorted(blueprint_dir.rglob("*.artifacts/*.tex")):
        original = tex_path.read_text(encoding="utf-8")
        sanitized = sanitize_blueprint_tex_text(original)
        if sanitized != original:
            tex_path.write_text(sanitized, encoding="utf-8")
            modified += 1
    return modified


def olean_path_for_source(source: pathlib.Path) -> pathlib.Path:
    rel = source.relative_to(SIGNALS_ROOT).with_suffix(".olean")
    return BUILD_DIR / "lib" / rel


def compute_module_hashes(sources: list[pathlib.Path]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for source in sources:
        digest = hashlib.sha256()
        digest.update(source.read_bytes())
        olean = olean_path_for_source(source)
        if olean.is_file():
            stat = olean.stat()
            digest.update(f":{stat.st_size}:{stat.st_mtime_ns}".encode("utf-8"))
        hashes[module_name(source)] = digest.hexdigest()
    return hashes


def compute_global_hash(architect_source_base: str) -> str:
    digest = hashlib.sha256()
    digest.update(pathlib.Path(__file__).read_bytes())
    lakefile = SIGNALS_ROOT / "lakefile.toml"
    if lakefile.is_file():
        digest.update(lakefile.read_bytes())
    digest.update((SIGNALS_ROOT / "lake-manifest.json").read_bytes())
    digest.update(architect_source_base.encode("utf-8"))
    digest.update(os.environ.get("DISABLE_EQUATIONS", "1").encode("utf-8"))
    for binary in (DOCGEN, DOCGEN_BATCH):
        if binary.is_file():
            st = binary.stat()
            digest.update(f":{binary.name}:{st.st_size}:{st.st_mtime_ns}".encode("utf-8"))
    return digest.hexdigest()


def load_cache_manifest() -> dict | None:
    if not CACHE_MANIFEST.is_file():
        return None
    try:
        return json.loads(CACHE_MANIFEST.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def save_cache_manifest(global_hash: str, module_hashes: dict[str, str]) -> None:
    CACHE_MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    CACHE_MANIFEST.write_text(
        json.dumps(
            {
                "version": 1,
                "global_hash": global_hash,
                "module_hashes": module_hashes,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )


def clear_generated_docs() -> None:
    DOC_DIR.mkdir(parents=True, exist_ok=True)
    for path in DOC_DIR.iterdir():
        if path.name in HOSTED_DOCS:
            continue
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()


def source_modules() -> list[pathlib.Path]:
    modules = list((SIGNALS_ROOT / "Signals").rglob("*.lean"))
    umbrella = SIGNALS_ROOT / "Signals.lean"
    if umbrella.is_file():
        modules.append(umbrella)
    return sorted(modules)


def module_name(source: pathlib.Path) -> str:
    return ".".join(source.relative_to(SIGNALS_ROOT).with_suffix("").parts)


def run_docgen_batch(sources: list[pathlib.Path], source_base: str) -> None:
    command = [str(DOCGEN_BATCH), str(BUILD_DIR), DATABASE.name]
    for source in sources:
        uri = source_base + source.relative_to(SIGNALS_ROOT).as_posix()
        command.extend((module_name(source), uri))

    started = time.perf_counter()
    if DOCGEN_DEBUG:
        print(f"[doc-gen4] batch analysis for {len(sources)} Signals modules", file=sys.stderr, flush=True)
    result = subprocess.run(
        command,
        cwd=SIGNALS_ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )
    if DOCGEN_PROFILE:
        elapsed = time.perf_counter() - started
        print(f"[profile] doc-gen4 batch ({len(sources)} modules): {elapsed:.3f}s", file=sys.stderr, flush=True)
    if result.returncode:
        sys.stderr.write(result.stdout)
        raise subprocess.CalledProcessError(result.returncode, command)


def main(argv: list[str] | None = None) -> None:
    args = sys.argv[1:] if argv is None else argv
    if "--sanitize-blueprint-tex" in args:
        repaired = sanitize_blueprint_tex(BLUEPRINT_DIR)
        if DOCGEN_DEBUG or repaired:
            print(f"[blueprint] sanitized {repaired} generated TeX artifact(s)")
        return

    if not DOCGEN.is_file():
        raise SystemExit(f"doc-gen4 executable not found: {DOCGEN}; build @doc-gen4/coreDocs first")
    if not DOCGEN_BATCH.is_file():
        raise SystemExit(f"Signals doc-gen batch executable not found: {DOCGEN_BATCH}; build signalsApiDocs first")

    manifest = json.loads((SIGNALS_ROOT / "lake-manifest.json").read_text(encoding="utf-8"))
    architect = next(package for package in manifest["packages"] if package.get("name") == "LeanArchitect")
    architect_source_base = (
        f"{github_web_url(architect['url'])}/blob/{architect['rev']}/"
    )
    try:
        remote_url = subprocess.check_output(
            ["git", "remote", "get-url", "origin"],
            cwd=PROJECT_ROOT,
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        remote_url = "https://github.com/westurner/sustainablefactory"
    try:
        commit = subprocess.check_output(
            ["git", "rev-parse", "HEAD"],
            cwd=PROJECT_ROOT,
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        commit = "main"
    source_base = f"{github_web_url(remote_url)}/blob/{commit}/src/signals/"

    sources = source_modules()
    global_hash = compute_global_hash(architect_source_base)
    module_hashes = compute_module_hashes(sources)
    cached = None if FORCE_REBUILD else load_cache_manifest()

    can_reuse_db = (
        cached is not None
        and cached.get("global_hash") == global_hash
        and DATABASE.is_file()
        and (DOC_DIR / "Signals.html").is_file()
        and set(cached.get("module_hashes", {})).issubset(module_hashes)
    )

    if can_reuse_db:
        cached_modules: dict[str, str] = cached.get("module_hashes", {})
        changed_sources = [
            src for src in sources if cached_modules.get(module_name(src)) != module_hashes[module_name(src)]
        ]
        if not changed_sources:
            print("Signals API docs unchanged; reusing cached output")
            return
        print(
            f"Signals API docs incremental update: {len(changed_sources)}/{len(sources)} module(s) changed"
        )
        batch_sources = changed_sources
    else:
        for suffix in ("", "-shm", "-wal"):
            pathlib.Path(f"{DATABASE}{suffix}").unlink(missing_ok=True)
        clear_generated_docs()
        MANIFEST.unlink(missing_ok=True)
        batch_sources = sources

    def run_docgen(*args: str) -> None:
        command = [str(DOCGEN), *args]
        started = time.perf_counter()
        if DOCGEN_DEBUG:
            print(f"[doc-gen4] {' '.join(command)}", file=sys.stderr, flush=True)
        result = subprocess.run(
            command,
            cwd=SIGNALS_ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=False,
        )
        if DOCGEN_PROFILE:
            elapsed = time.perf_counter() - started
            module = args[3] if args[0] == "single" else "render database"
            print(f"[profile] doc-gen4 {module}: {elapsed:.3f}s", file=sys.stderr, flush=True)
        if result.returncode:
            sys.stderr.write(result.stdout)
            raise subprocess.CalledProcessError(result.returncode, command)

    run_docgen_batch(batch_sources, source_base)

    run_docgen(
        "fromDb",
        "--build",
        str(BUILD_DIR),
        "--manifest",
        str(MANIFEST),
        DATABASE.relative_to(SIGNALS_ROOT).as_posix(),
    )
    rewrite_html_links(DOC_DIR, architect_source_base)
    save_cache_manifest(global_hash, module_hashes)


if __name__ == "__main__":
    main()