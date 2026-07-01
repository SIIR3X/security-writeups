#!/usr/bin/env bash
#
# Export a write-up to a formal PDF report from its Markdown source.
#
# Usage:
#   ./build-pdf.sh [path-to-writeup-dir]
#
# With no argument it builds the write-up in the current directory.
# The PDF is written next to the README.md, named after the write-up folder.
#
# Requires: pandoc and a LaTeX engine (xelatex).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILTER="$ROOT/templates/center-images.lua"
HEADER="$ROOT/templates/pdf-header.tex"
TEMPLATE="$ROOT/templates/writeup.latex"

DIR="${1:-.}"
if [[ ! -f "$DIR/README.md" ]]; then
  echo "error: no README.md found in '$DIR'" >&2
  exit 1
fi

cd "$DIR"
NAME="$(basename "$PWD")"

pandoc README.md \
  --output "$NAME.pdf" \
  --pdf-engine=xelatex \
  --template="$TEMPLATE" \
  --lua-filter="$FILTER" \
  --toc \
  --include-in-header="$HEADER" \
  --variable geometry:margin=2.5cm \
  --variable colorlinks=true \
  --variable linkcolor=RoyalBlue \
  --variable urlcolor=RoyalBlue \
  --variable toccolor=black

echo "built: $DIR/$NAME.pdf"
