#!/usr/bin/env python3
"""
manage.py -- a port of the Makefile tasks
"""

import argparse
import logging
import os
import shlex
import subprocess
import sys


# Setup Logging
class ColorFormatter(logging.Formatter):
    RED = "\033[91m"
    RESET = "\033[0m"

    def format(self, record):
        if record.levelno >= logging.ERROR:
            record.msg = f"{self.RED}{record.msg}{self.RESET}"
        return super().format(record)


logger = logging.getLogger("manage")


def setup_logging(log_file=None, verbose=False, quiet=False):
    """Configure logging handlers."""
    logger.setLevel(logging.DEBUG)

    # Console Handler
    ch = logging.StreamHandler(sys.stdout)
    if quiet:
        ch.setLevel(logging.ERROR)
    elif verbose:
        ch.setLevel(logging.DEBUG)
    else:
        ch.setLevel(logging.INFO)

    ch.setFormatter(ColorFormatter("%(levelname)s: %(message)s"))
    logger.addHandler(ch)

    # File Handler
    if log_file:
        log_path = os.path.dirname(log_file)
        if log_path:
            os.makedirs(log_path, exist_ok=True)
        fh = logging.FileHandler(log_file)
        fh.setLevel(logging.DEBUG)
        fh.setFormatter(
            logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
        )
        logger.addHandler(fh)


def run_command(command, cwd=None):
    """Utility to run a shell command and exit on failure."""
    logger.info(
        f"Executing: {' '.join(shlex.quote(part) for part in command) if isinstance(command, list) else command}"
    )
    try:
        # Use shell=True for strings, or pass list directly
        is_shell = isinstance(command, str)
        subprocess.check_call(command, shell=is_shell, cwd=cwd)
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed with exit code {e.returncode}")
        sys.exit(e.returncode)
    except FileNotFoundError as e:
        logger.error(f"{e}")
        sys.exit(1)


def build_docs():
    """Build sphinx documentation."""
    run_command(["make", "-C", "docs", "html"])


def aggregate_data(input_dir=None, output=None):
    """Run the technical data aggregation tool."""
    script_path = os.path.join("tools", "aggregate_technical_data.py")
    cmd = [sys.executable, script_path]
    if input_dir:
        cmd.extend(["--input-dir", input_dir])
    if output:
        cmd.extend(["--output", output])
    run_command(cmd)


def transform_md(indir=None, outdir=None):
    """Run transform-md with project defaults equivalent to Makefile."""
    run_command(
        [sys.executable, "data/create_symlinks.py", "--config", "docs/_toc.yml", "--quiet"]
    )
    command = [
        "transform-md",
        "--indir",
        indir or "data/chatoverlay/chats__all/",
        "--outdir",
        outdir or "docs/chats/",
        "--transform-cell-split",
        "m1",
        "--out-format=myst,ipynb",
    ]
    run_command(command)


def transform_md_data_chats(outdir=None):
    """Run transform-md over data/chats, matching Makefile target."""
    transform_md(indir="data/chats/", outdir=outdir or "docs/chats/")


def update_schemadir():
    """Update RDF schemas using schematool."""
    run_command(["schematool"])


def build_all():
    """Run full build pipeline: aggregate_data -> transform_md_all -> docs."""
    aggregate_data()
    transform_md()
    build_docs()


def run_tests():
    """Run pytest suite, matching Makefile test target."""
    run_pytest()


def run_pytest():
    """Run pytest suite."""
    run_command(["pytest", "--cov=.", "--cov-report=term-missing", "."])


def run_e2etest():
    """Run end-to-end Playwright tests on host."""
    run_command(["./e2etest.sh", "--on-host"])


def serve_docs(port=8000):
    """Serve built docs over HTTP and print a short tree summary if available."""
    run_command(
        '(type -a tree && tree -a -L 2 ./docs/_build/html) || true'
    )
    run_command([
        sys.executable,
        "-m",
        "http.server",
        str(port),
        "--directory",
        "docs/_build/html",
    ])


def main():
    parser = argparse.ArgumentParser(
        description="Management script for the Sustainable Factory project.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    # Global options
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Increase output verbosity"
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true", help="Decrease output verbosity"
    )
    parser.add_argument("--log-output", help="Path to log file")

    subparsers = parser.add_subparsers(dest="command", help="The command to execute")

    # Docs command
    subparsers.add_parser(
        "docs",
        help="Build HTML documentation using Sphinx",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    # Aggregate command
    agg_parser = subparsers.add_parser(
        "aggregate",
        help="Aggregate technical and economic data from MyST files",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    agg_parser.add_argument(
        "--input-dir",
        default="data/chats",
        help="Directory containing input .md and .json files",
    )
    agg_parser.add_argument(
        "--output", default="docs/tables_and_figures.myst.md", help="Output file path"
    )

    agg_alias_parser = subparsers.add_parser(
        "aggregate-chats",
        help="Alias for aggregate",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    agg_alias_parser.add_argument(
        "--input-dir",
        default="data/chats",
        help="Directory containing input .md and .json files",
    )
    agg_alias_parser.add_argument(
        "--output",
        default="docs/tables_and_figures.myst.md",
        help="Output file path",
    )

    agg_data_parser = subparsers.add_parser(
        "aggregate_data",
        help="Aggregate technical data from documents",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    agg_data_parser.add_argument(
        "--input-dir",
        default="data/chats",
        help="Directory containing input .md and .json files",
    )
    agg_data_parser.add_argument(
        "--output",
        default="docs/tables_and_figures.myst.md",
        help="Output file path",
    )

    agg_data_alias_parser = subparsers.add_parser(
        "aggregate-data",
        help="Alias for aggregate_data",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    agg_data_alias_parser.add_argument(
        "--input-dir",
        default="data/chats",
        help="Directory containing input .md and .json files",
    )
    agg_data_alias_parser.add_argument(
        "--output",
        default="docs/tables_and_figures.myst.md",
        help="Output file path",
    )

    # Transform command
    trans_parser = subparsers.add_parser(
        "transform",
        help="Transform markdown files in data/chatoverlay/chats__all/",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    trans_parser.add_argument(
        "--indir", default="data/chatoverlay/chats__all/", help="Input directory"
    )
    trans_parser.add_argument(
        "--outdir", default="docs/chats/", help="Output directory"
    )

    transform_all_parser = subparsers.add_parser(
        "transform_md_all",
        help="Transform markdown chat exports from chatoverlay to docs",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    transform_all_parser.add_argument(
        "--indir", default="data/chatoverlay/chats__all/", help="Input directory"
    )
    transform_all_parser.add_argument(
        "--outdir", default="docs/chats/", help="Output directory"
    )

    transform_all_alias_parser = subparsers.add_parser(
        "transform-md-all",
        help="Alias for transform_md_all",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    transform_all_alias_parser.add_argument(
        "--indir", default="data/chatoverlay/chats__all/", help="Input directory"
    )
    transform_all_alias_parser.add_argument(
        "--outdir", default="docs/chats/", help="Output directory"
    )

    transform_data_parser = subparsers.add_parser(
        "transform_md_data_chats",
        help="Transform markdown chat exports from data/chats to docs",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    transform_data_parser.add_argument(
        "--outdir", default="docs/chats/", help="Output directory"
    )

    transform_data_alias_parser = subparsers.add_parser(
        "transform-md-data-chats",
        help="Alias for transform_md_data_chats",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    transform_data_alias_parser.add_argument(
        "--outdir", default="docs/chats/", help="Output directory"
    )

    # Build command
    subparsers.add_parser(
        "build",
        help="Full build pipeline (aggregate_data, transform_md_all, docs)",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    # Update schema command
    subparsers.add_parser(
        "update_schemadir",
        help="Update RDF schemas using schematool",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    subparsers.add_parser(
        "update-schemadir",
        help="Alias for update_schemadir",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    # Test command
    subparsers.add_parser(
        "test",
        help="Run test suite",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    # Pytest command
    subparsers.add_parser(
        "pytest",
        help="Run the full pytest suite",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    subparsers.add_parser(
        "run-tests",
        help="Alias for pytest",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    # E2E test command
    subparsers.add_parser(
        "e2etest",
        help="Run end-to-end tests with Playwright",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    subparsers.add_parser(
        "e2e-test",
        help="Alias for e2etest",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    # Serve command
    serve_parser = subparsers.add_parser(
        "serve",
        help="Serve docs with HTTP server",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    serve_parser.add_argument(
        "--port", type=int, default=8000, help="Port to bind HTTP server"
    )

    serve_alias_parser = subparsers.add_parser(
        "serve-docs",
        help="Alias for serve",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    serve_alias_parser.add_argument(
        "--port", type=int, default=8000, help="Port to bind HTTP server"
    )

    args = parser.parse_args()

    setup_logging(log_file=args.log_output, verbose=args.verbose, quiet=args.quiet)

    if args.command == "docs":
        build_docs()
    elif args.command in {
        "aggregate",
        "aggregate_data",
        "aggregate-data",
        "aggregate-chats",
    }:
        aggregate_data(input_dir=args.input_dir, output=args.output)
    elif args.command == "transform":
        transform_md(indir=args.indir, outdir=args.outdir)
    elif args.command in {"transform_md_all", "transform-md-all"}:
        transform_md(indir=args.indir, outdir=args.outdir)
    elif args.command in {"transform_md_data_chats", "transform-md-data-chats"}:
        transform_md_data_chats(outdir=args.outdir)
    elif args.command in {"update_schemadir", "update-schemadir"}:
        update_schemadir()
    elif args.command == "build":
        build_all()
    elif args.command == "test":
        run_tests()
    elif args.command in {"pytest", "run-tests"}:
        run_pytest()
    elif args.command in {"e2etest", "e2e-test"}:
        run_e2etest()
    elif args.command in {"serve", "serve-docs"}:
        serve_docs(port=args.port)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
