# Evidence-to-policy figures

The single source for the "Truth → Research → Policy Analysis → Policy Makers →
Support / Oppose" diagram used across Fernando Hoces de la Guardia's papers,
slides and website.

## Contents

| Path | What it is |
|---|---|
| `src/evidence-to-policy.tex` | Standalone TikZ source for the main diagram: web, paper and two highlight variants |
| `out/evidence-to-policy-web.*` | Web variant: all circles 2.4cm. PDF, 300 dpi PNG, SVG (white background) and `-transparent.svg` |
| `out/evidence-to-policy-paper.*` | Paper variant: Research circle 2.0cm. PDF, 400 dpi PNG, SVG and `-transparent.svg` |
| `out/evidence-to-policy-web-highlight-research.*` | Web variant with the Research circle and its arrow to Policy Analysis highlighted in blue |
| `out/evidence-to-policy-web-highlight-analysis.*` | Web variant with only the Policy Analysis circle highlighted in blue |
| `src/evidence-to-policy-competing.tex` | Second source: one piece of research feeds three competing policy analyses (redrawn from the dissertation) |
| `out/evidence-to-policy-competing.*` | Competing-analyses figure. PDF, 300 dpi PNG, SVG and `-transparent.svg` |
| `src/evidence-to-policy-competing-research.tex` | Third source: three studies with different findings, each feeding three competing analyses (redrawn from the dissertation) |
| `out/evidence-to-policy-competing-research.*` | Competing-research figure. PDF, 300 dpi PNG, SVG and `-transparent.svg` |
| `static/e2p_slide.png` | Full-slide render used as a slide background; no source, kept as is |
| `consumers.tsv` | Which file goes to which project on this machine |

The SVGs keep the Computer Modern glyphs as paths, so they need no fonts.

## Updating a figure

1. Edit `src/evidence-to-policy.tex`.
2. Commit. The pre-commit hook runs `./build.sh` and stages the rebuilt `out/`.
   The post-commit hook then runs `./sync.sh`, which copies the committed files
   into every project listed in `consumers.tsv`.
3. In each updated project, review the copied files and commit them there.
   `sync.sh` never commits or pushes in other repos.

`git pull` runs the same sync through the post-merge hook. Builds are
byte-reproducible, so rebuilding an unchanged source leaves git clean.

To add a project, add a line to `consumers.tsv`. The destination path is
relative to the folder that holds this repo (`~/Desktop/sandbox`).

## Setup after a fresh clone

The hooks live in `hooks/` and are enabled per clone:

```sh
git config core.hooksPath hooks
```

Building needs `pdflatex`, Ghostscript (`gs`) and Python with PyMuPDF (`fitz`).

## Known copies not synced

The paper variant also lives in two co-author projects, deliberately left out of
`consumers.tsv`: `overleaf-new/assets/` and
`RGPB_repos/rgpb-phase2-clean-analyse/docs/paper/assets/`. Update those by hand
if the paper variant changes.
