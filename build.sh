#!/bin/bash
# Build every variant of the evidence-to-policy diagram into out/.
# Outputs are byte-reproducible (fixed SOURCE_DATE_EPOCH, no PDF trailer id),
# so rebuilding an unchanged source leaves git clean.
set -euo pipefail
cd "$(dirname "$0")"
export SOURCE_DATE_EPOCH=0 FORCE_SOURCE_DATE=1
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

build() {  # $1 = variant name, $2 = TeX prelude, $3 = PNG dpi, $4 = source (default: the main diagram)
  local name="evidence-to-policy-$1"
  pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$TMP" \
    -jobname="$name" "$2\\input{${4:-src/evidence-to-policy.tex}}" > "$TMP/$name.out" \
    || { cat "$TMP/$name.out"; exit 1; }
  cp "$TMP/$name.pdf" "out/$name.pdf"
  gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=png16m -r"$3" \
    -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile="out/$name.png" "out/$name.pdf"
}
build web   ""                    300
build paper "\\def\\paperversion{}" 400
build web-highlight-research "\\def\\highlightresearch{}" 300
build web-highlight-analysis "\\def\\highlightanalysis{}" 300
build web-from-analysis "\\def\\fromanalysis{}" 300
build competing "" 300 src/evidence-to-policy-competing.tex
build competing-from-analysis "\\def\\fromanalysis{}" 300 src/evidence-to-policy-competing.tex
build competing-from-analysis-blackbox "\\def\\fromanalysis{}\\def\\blackbox{}" 300 src/evidence-to-policy-competing.tex
build competing-from-analysis-opa "\\def\\fromanalysis{}\\def\\opaicon{}" 300 src/evidence-to-policy-competing.tex
build competing-from-analysis-opa-third "\\def\\fromanalysis{}\\def\\opaicon{}\\def\\thirdopa{}" 300 src/evidence-to-policy-competing.tex
build competing-research "" 300 src/evidence-to-policy-competing-research.tex

# Vector SVGs with the Computer Modern glyphs as paths: a white-background
# copy and a transparent one (the website inverts it in dark mode).
python3 - <<'PY'
import fitz
DESC = {
    "main": "Truth feeds research, research feeds policy analysis, and the same policy analysis leads Policy Maker 1 to support a policy and Policy Maker 2 to oppose it.",
    "competing-research": "Truth feeds three studies with different findings, from a large effect to a small one. Each study feeds three competing policy analyses. Policy Maker 1 follows an analysis showing large gains only and supports the policy; Policy Maker 2 follows one showing large losses only and opposes it.",
    "web-from-analysis": "One policy analysis leads Decision Maker 1 to support a policy and Decision Maker 2 to oppose it.",
    "competing-from-analysis": "Two competing policy analyses of the same policy: one shows only gains, the other only losses. Decision Maker 1 follows the only-gains analysis and supports the policy; Decision Maker 2 follows the only-losses analysis and opposes it.",
    "competing-from-analysis-blackbox": "Two competing policy analyses of the same policy, drawn as closed black cubes: one shows only gains and leads Decision Maker 1 to support the policy; the other shows only losses and leads Decision Maker 2 to oppose it.",
    "competing-from-analysis-opa": "Two competing policy analyses of the same policy, each shown as an Open Policy Analysis with its output, assumptions, details and materials open: one shows only gains and leads Decision Maker 1 to support the policy; the other shows only losses and leads Decision Maker 2 to oppose it.",
    "competing-from-analysis-opa-third": "Two competing policy analyses, each an Open Policy Analysis, and a third Open Policy Analysis between them, drawn from both; Decision Maker 1 still follows the only-gains analysis and Decision Maker 2 the only-losses analysis.",
    "competing": "Truth feeds research, and the same research feeds three competing policy analyses: only gains, gains and losses, and only losses. Policy Maker 1 follows the only-gains analysis and supports the policy; Policy Maker 2 follows the only-losses analysis and opposes it.",
}
for v in ("web", "paper", "web-highlight-research", "web-highlight-analysis", "web-from-analysis", "competing", "competing-from-analysis", "competing-from-analysis-blackbox", "competing-from-analysis-opa", "competing-from-analysis-opa-third", "competing-research"):
    TITLE = f"<title>From evidence to policy</title><desc>{DESC.get(v, DESC['main'])}</desc>"
    svg = fitz.open(f"out/evidence-to-policy-{v}.pdf")[0].get_svg_image(text_as_path=True)
    i = svg.index(">", svg.index("<svg")) + 1
    for suffix, extra in (("", '<rect width="100%" height="100%" fill="#FFFFFF"/>'), ("-transparent", "")):
        with open(f"out/evidence-to-policy-{v}{suffix}.svg", "w") as f:
            f.write(svg[:i] + "\n" + TITLE + extra + svg[i:])
PY
echo "built: $(ls out | tr '\n' ' ')"
