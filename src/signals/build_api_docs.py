"""Build Signals API pages without generating dependency documentation."""

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
DOCGEN_PROFILE = os.environ.get("SIGNALS_DOCGEN_PROFILE") == "1"
DOCGEN_DEBUG = os.environ.get("SIGNALS_DOCGEN_DEBUG") == "1"


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

        html_path.write_text(HREF_ATTRIBUTE.sub(replace_href, content), encoding="utf-8")


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


def main() -> None:
    if not DOCGEN.is_file():
        raise SystemExit(f"doc-gen4 executable not found: {DOCGEN}; build @doc-gen4/coreDocs first")
    if not DOCGEN_BATCH.is_file():
        raise SystemExit(f"Signals doc-gen batch executable not found: {DOCGEN_BATCH}; build signalsApiDocs first")

    manifest = json.loads((SIGNALS_ROOT / "lake-manifest.json").read_text(encoding="utf-8"))
    architect = next(package for package in manifest["packages"] if package.get("name") == "LeanArchitect")
    architect_source_base = (
        f"{github_web_url(architect['url'])}/blob/{architect['rev']}/"
    )
    source_base = subprocess.check_output(
        ["git", "remote", "get-url", "origin"], cwd=PROJECT_ROOT, text=True
    ).strip()
    commit = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=PROJECT_ROOT, text=True
    ).strip()
    source_base = f"{github_web_url(source_base)}/blob/{commit}/src/signals/"

    for suffix in ("", "-shm", "-wal"):
        pathlib.Path(f"{DATABASE}{suffix}").unlink(missing_ok=True)
    clear_generated_docs()
    MANIFEST.unlink(missing_ok=True)

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

    run_docgen_batch(source_modules(), source_base)

    run_docgen(
        "fromDb",
        "--build",
        str(BUILD_DIR),
        "--manifest",
        str(MANIFEST),
        DATABASE.relative_to(SIGNALS_ROOT).as_posix(),
    )
    rewrite_html_links(DOC_DIR, architect_source_base)


if __name__ == "__main__":
    main()