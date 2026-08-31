"""
aggregate_technical_data.py
"""

import argparse
import glob
import json
import logging
import os
import sys
from typing import TextIO

from sustainablefactory.parser import parse_and_extract_from_markdown


# Setup Logging
class ColorFormatter(logging.Formatter):
    RED = "\033[91m"
    RESET = "\033[0m"

    def format(self, record: logging.LogRecord) -> str:
        if record.levelno >= logging.ERROR:
            record.msg = f"{self.RED}{record.msg}{self.RESET}"
        return super().format(record)


logger = logging.getLogger("aggregate_technical_data")


def setup_logging(
    log_file: str | None = None, verbose: bool = False, quiet: bool = False
) -> None:
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


def get_files(input_dir: str) -> list[str]:
    """
    Retrieve and sort markdown and json files from the directory.

    Args:
        input_dir (str): Directory to search in.

    Returns:
        list: Sorted list of file paths.
    """
    files = glob.glob(os.path.join(input_dir, "*.md")) + glob.glob(
        os.path.join(input_dir, "*.json")
    )
    return sorted(files)


def generate_report_content(files: list[str], output: TextIO) -> None:
    """
    Iterate through files, extract data, and write to the output handle.

    Args:
        files (list): list of file paths to process.
        output_handle (file object): File-like object to write output to.
    """

    write = output.write
    flush = output.flush

    write("# All Technical and Economic Data\n\n")
    write(
        "This document contains tables, cost figures, metrics, materials, equipment, and citations extracted from the workspace.\n\n"
    )

    for file_path in files:
        file_name = os.path.basename(file_path)
        logger.info(f"Processing {file_name}...")

        steps = parse_and_extract_from_markdown(file_path)
        if not steps:
            logger.warning(f"No steps found in {file_name}")
            continue

        write(f"## {file_name}\n\n")

        for step in steps:
            flush()

            if step.label != "File Summary":
                write(f"### {step.label}\n\n")

            if step.cost_figures:
                write("#### Cost Figures\n\n")
                write(", ".join([f"`{c}`" for c in step.cost_figures]) + "\n\n")

            if hasattr(step, "metrics") and step.metrics:
                write("#### Performance Metrics\n\n")
                for m in step.metrics:
                    write(f"- {m}\n")
                write("\n")

            if hasattr(step, "materials") and step.materials:
                write("#### Materials & Chemicals\n\n")
                write(", ".join([f"`{m}`" for m in step.materials]) + "\n\n")

            if hasattr(step, "equipment") and step.equipment:
                write("#### Equipment & Tools\n\n")
                write(", ".join([f"`{e}`" for e in step.equipment]) + "\n\n")

            if hasattr(step, "latex_math") and step.latex_math:
                write("#### Mathematical Formulas\n\n")
                for m in step.latex_math:
                    write(f"- ${m}$\n")
                write("\n")

            if hasattr(step, "citations") and step.citations:
                write("#### Citations & Sources\n\n")
                for c in step.citations:
                    write(f"- {c}\n")
                write("\n")

            if step.tables:
                write("#### Tables\n\n")
                for table in step.tables:
                    headers = table["headers"]
                    write("| " + " | ".join(headers) + " |\n")
                    write("| " + " | ".join(["---"] * len(headers)) + " |\n")
                    for row in table["rows"]:
                        write(
                            "| "
                            + " | ".join([row.get(h, "") for h in headers])
                            + " |\n"
                        )
                    write("\n\n")

            flush()

        write("---\n\n")


def generate_jsonld_content(files: list[str], output: TextIO) -> None:
    """
    Iterate through files, extract data, and write JSON-LD to the output handle.

    Args:
        files (list): list of file paths to process.
        output (file object): File-like object to write output to.
    """
    graph = []

    for file_path in files:
        steps = parse_and_extract_from_markdown(file_path)
        if not steps:
            continue

        for step in steps:
            # Construct the node with available attributes
            node = {
                "@type": "sf:Process",
                "rdfs:label": step.label,
            }

            if hasattr(step, "id") and step.id:
                node["@id"] = step.id

            if hasattr(step, "metrics") and step.metrics:
                node["sf:metric"] = step.metrics

            if hasattr(step, "cost_figures") and step.cost_figures:
                node["sf:costEstimate"] = step.cost_figures

            if hasattr(step, "materials") and step.materials:
                node["sf:usesMaterial"] = step.materials

            if hasattr(step, "equipment") and step.equipment:
                node["sf:usesEquipment"] = step.equipment

            if hasattr(step, "latex_math") and step.latex_math:
                node["sf:formula"] = step.latex_math

            if hasattr(step, "citations") and step.citations:
                node["sf:citation"] = step.citations

            graph.append(node)

    context = {
        "sf": "https://westurner.github.io/sustainablefactory/process/#",
        "iof": "https://spec.industrialontologies.org/ontology/core/Core/",
        "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
        "xsd": "http://www.w3.org/2001/XMLSchema#",
    }

    doc = {"@context": context, "@graph": graph}

    json.dump(doc, output, indent=2)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Aggregate technical and economic data from (MyST) Markdown files.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--input-dir",
        default="data/chats",
        help="Directory containing input .md and .json files",
    )
    parser.add_argument(
        "--output", default="docs/tables_and_figures.myst.md", help="Output file path"
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Increase output verbosity"
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true", help="Decrease output verbosity"
    )
    parser.add_argument("--log-output", help="Path to log file")
    args = parser.parse_args()

    setup_logging(log_file=args.log_output, verbose=args.verbose, quiet=args.quiet)

    files = get_files(args.input_dir)

    logger.info(f"Found {len(files)} files in {args.input_dir}")
    for f_path in files:
        logger.debug(f"Found file: {f_path}")

    output_path = args.output

    with open(output_path, "w") as output_file:
        generate_report_content(files, output_file)


if __name__ == "__main__":
    main()
