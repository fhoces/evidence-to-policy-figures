# Working in this repo

This repo is the single source for the evidence-to-policy diagram. Other
projects on this machine hold COPIES of its outputs; never edit those copies,
edit here and let the sync carry the change.

## Layout

- `src/evidence-to-policy.tex`: the one TikZ source. Two variants from one file:
  `\paperversion` undefined = web (all circles 2.4cm); defined = paper
  (Research circle 2.0cm), set via `\researchsize`.
- `build.sh`: builds both variants into `out/` (pdflatex, then Ghostscript PNG at
  300 dpi web / 400 dpi paper, then PyMuPDF SVGs with glyphs as paths, white and
  `-transparent`). Byte-reproducible: an unchanged source rebuilds to identical
  bytes, so a no-op build leaves git clean.
- `static/e2p_slide.png`: a full-slide render with no source. Copied as is.
- `consumers.tsv`: repo file -> destination, relative to `~/Desktop/sandbox`.
- `sync.sh`: copies each file from HEAD (committed version, not the working tree)
  to its destination, only when bytes differ. Never commits in other repos.
- `hooks/`: enabled with `git config core.hooksPath hooks` (already set here).
  pre-commit rebuilds and stages `out/` when `src/` or `build.sh` is staged;
  post-commit and post-merge run `sync.sh`.

## Editing a figure

1. Edit `src/evidence-to-policy.tex`. Decide whether the change is for both
   variants or only one (use the `\paperversion` switch for variant-specific
   changes).
2. Optional preview: `./build.sh`, then Read `out/evidence-to-policy-web.png`
   (or `-paper.png`) to check it visually before committing.
3. `git add src/ && git commit`. The hooks rebuild, stage `out/` and sync. The
   commit output lists each `sync: updated <path>`.
4. Verify: `cmp out/<file> ~/Desktop/sandbox/<destination>` for each updated
   path (see `consumers.tsv`).
5. Tell the user which projects now have uncommitted figure changes. Those
   projects are owned by other sessions/the user; do not commit or push there.
   Consumers today: `personal-website` (web variant, three files in
   `files/figures/`; its `docs/` copy updates on the site's next `quarto render`),
   `Registration-Tips-2026-slides` (paper PNG + e2p_slide.png),
   `BITSS-AM-2026-slides`, `SEIC-RGPB-slides` (e2p_slide.png only).

Adding a consumer: add a line to `consumers.tsv`, commit, and the post-commit
sync writes it. Renaming an output means updating `consumers.tsv` in the same
commit.

## Not synced on purpose

The paper variant also lives in `overleaf-new/assets/` and
`RGPB_repos/rgpb-phase2-clean-analyse/docs/paper/assets/` (co-author projects).
If the paper variant changes, tell the user those need a manual update; do not
write there.

## Other rules

- No em-dashes in anything user-visible, commit messages included.
- Pushing to GitHub needs the user's explicit go-ahead in the current session.
- `static/e2p_slide.png` has no source: if the diagram changes, flag to the user
  that this slide render is now out of date rather than trying to regenerate it.
