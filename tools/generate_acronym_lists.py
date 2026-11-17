"""Generate acronym occurrence and unique-term lists from project sources."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ACRONYM_PATTERN  = re.compile(r"\b([A-Z]{1,}-[A-Z-a-z]{2,})")
#ACRONYM_PATTERN = re.compile(r"\b([A-Z]{2,}|[A-Z]{1,}-[A-Z-a-z]{2,})")
#ACRONYM_PATTER2 = re.compile(r"\b([A-Z]{2,})")
OUTPUT_FILENAMES = (
    "acronyms_unsorted.txt",
    "acronyms_sorted.txt",
    "acronyms_unique.txt",
)


def source_paths() -> list[Path]:
    paths = [
        *(ROOT / "src" / "signals" / "Signals").glob("*.lean"),
        *(ROOT / "docs").glob("*.md"),
        #(ROOT / "data" / "chats").glob("*.md"),
        *(ROOT / "docs" / "chats").glob("*.md"),
    ]
    return sorted(paths, key=lambda path: path.relative_to(ROOT).as_posix())


def occurrence_records() -> list[str]:
    #records = []
    for path in source_paths():
        source = f"./{path.relative_to(ROOT).as_posix()}"
        for line_number, line in enumerate(
            path.read_text(encoding="utf-8").splitlines(), start=1
        ):
            for match in ACRONYM_PATTERN.finditer(line):
                yield (source, line_number, match.group(1))
                #records.append(f"{match.group(0)}\t{source}\t{line_number}")
    #return records


def write_lines(path: Path, lines: list[str]) -> None:
    contents = "\n".join(lines)
    if contents:
        contents += "\n"
    path.write_text(contents, encoding="utf-8")


def generate(output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    records = occurrence_records()
    sorted_records = sorted(records)
    unique_terms = sorted({record.split("\t", maxsplit=1)[0] for record in records})
    outputs = [records, sorted_records, unique_terms]

    for filename, lines in zip(OUTPUT_FILENAMES, outputs, strict=True):
        output_path = output_dir / filename
        write_lines(output_path, lines)
        print(f"Generated {output_path} ({output_path.stat().st_size} bytes)")


def generate_pandas(output_dir: Path) -> None:
    """
    sort match results by (match,file,lineno)
    """


    import pandas as pd
    pd.set_option('display.max_rows', None)
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', None)

    records = occurrence_records()

    df = pd.DataFrame.from_records(records, columns=['file','lineno','match'])
    df['lineno'] = df['lineno'].astype(int)
    df["match_lower"] = (df["match"]
        .str.removesuffix("s")
        .str.lower()
        .str.removesuffix("-"))
    df = df[["match_lower", "match", "file", "lineno"]]

    #print(df)
    #breakpoint()

    df_sorted = df.sort_values(by=["match_lower", "file", "lineno"])
    #del df_sorted["match_lower"]
    print(df_sorted.to_csv(index=False))

    records = df  #.values.tolist()
    sorted_records = df_sorted  #.values.tolist()
    unique_terms = df["match"].drop_duplicates().sort_values()


    output_dir.mkdir(parents=True, exist_ok=True)

    output_filenames = OUTPUT_FILENAMES
    outputs = [records, sorted_records, unique_terms]
    
    for filename, lines in zip(output_filenames, outputs, strict=True):
        output_path = output_dir / filename

        lines.to_csv(output_path, index=False)
        #print(lines)
        #write_lines(output_path, lines)
        print(f"Generated {output_path} ({output_path.stat().st_size} bytes)")

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=ROOT / "docs",
        help="directory for generated acronym lists (default: docs)",
    )
    args = parser.parse_args()
    output_dir = args.output_dir
    if not output_dir.is_absolute():
        output_dir = ROOT / output_dir
    
    #generate(output_dir)
    generate_pandas(output_dir)


if __name__ == "__main__":
    main()