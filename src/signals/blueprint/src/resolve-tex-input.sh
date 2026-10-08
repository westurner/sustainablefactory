#!/usr/bin/env bash
set -euo pipefail

candidate="$1"
if [[ -f "$candidate" ]]; then
	realpath "$candidate"
elif [[ -f "$candidate.tex" ]]; then
	realpath "$candidate.tex"
else
	exit 1
fi