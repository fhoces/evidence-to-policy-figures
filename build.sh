#!/bin/bash
# Build both variants of the evidence-to-policy diagram into out/.
# Outputs are byte-reproducible (fixed SOURCE_DATE_EPOCH, no PDF trailer id),
# so rebuilding an unchanged source leaves git clean.
set -euo pipefail
cd "$(dirname "$0")"
export SOURCE_DATE_EPOCH=0 FORCE_SOURCE_DATE=1
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

build() {  # $1 = variant name, $2 = TeX prelude, $3 = PNG dpi
  local name="evidence-to-policy-$1"
  pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$TMP" \
    -jobname="$name" "$2\\input{src/evidence-to-policy.tex}" > "$TMP/$name.out" \
    || { cat "$TMP/$name.out"; exit 1; }
  cp "$TMP/$name.pdf" "out/$name.pdf"
  gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=png16m -r"$3" \
    -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile="out/$name.png" "out/$name.pdf"
}
build web   ""                    300
build paper "\\def\\paperversion{}" 400

# Vector SVGs with the Computer Modern glyphs as paths: a white-background
# copy and a transparent one (the website inverts it in dark mode).
python3 - <<'PY'
import fitz
TITLE = "<title>From evidence to policy</title><desc>Truth feeds research, research feeds policy analysis, and the same policy analysis leads Policy Maker 1 to support a policy and Policy Maker 2 to oppose it.</desc>"
for v in ("web", "paper"):
    svg = fitz.open(f"out/evidence-to-policy-{v}.pdf")[0].get_svg_image(text_as_path=True)
    i = svg.index(">", svg.index("<svg")) + 1
    for suffix, extra in (("", '<rect width="100%" height="100%" fill="#FFFFFF"/>'), ("-transparent", "")):
        with open(f"out/evidence-to-policy-{v}{suffix}.svg", "w") as f:
            f.write(svg[:i] + "\n" + TITLE + extra + svg[i:])
PY
echo "built: $(ls out | tr '\n' ' ')"
