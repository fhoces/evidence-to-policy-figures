#!/bin/bash
# Copy the COMMITTED figures (HEAD, not the working tree) into every project
# listed in consumers.tsv. Only files whose bytes differ are written; nothing
# is committed in the destination repos. Run by the post-commit and
# post-merge hooks, or by hand.
set -uo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"; BASE="$(dirname "$REPO")"
changed=0
while IFS=$'\t' read -r src dest; do
  [[ -z "$src" || "$src" == \#* ]] && continue
  target="$BASE/$dest"
  if [[ ! -d "$(dirname "$target")" ]]; then
    echo "sync: skip $dest (folder missing)"; continue
  fi
  tmp=$(mktemp)
  if ! git -C "$REPO" show "HEAD:$src" > "$tmp" 2>/dev/null; then
    echo "sync: $src is not committed, skipped"; rm -f "$tmp"; continue
  fi
  if ! cmp -s "$tmp" "$target"; then
    cp "$tmp" "$target"; echo "sync: updated $dest"; changed=1
  fi
  rm -f "$tmp"
done < "$REPO/consumers.tsv"
[[ $changed == 0 ]] && echo "sync: all copies already match HEAD"
exit 0
