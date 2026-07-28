#!/usr/bin/env bash
# Publish an image to the public BSS media repo and print its raw URL.
#
#   ./publish.sh "/path/to/01_ps5-pro-who-its-for.jpg"
#   ./publish.sh "/path/to/photo.jpg" custom-name.jpg
#
# The printed URL is what goes into Zapier's `source` parameter, or Instagram's
# `image_url`. Both fetch the image themselves and cannot read a local file.
#
# Images are committed under images/YYYY-MM-DD/ so a repost never silently
# overwrites an older poster.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GH_USER="aaronmalong"
GH_REPO="bss-gaming-media"

die() { echo "ERROR: $*" >&2; exit 1; }

[ $# -ge 1 ] || die "usage: publish.sh <image-path> [target-filename]"

SRC="$1"
[ -f "$SRC" ] || die "no such file: $SRC"

# macOS ships bash 3.2, which has no ${var,,} lowercase operator, so use tr.
SRC_LOWER=$(printf '%s' "$SRC" | tr '[:upper:]' '[:lower:]')
case "$SRC_LOWER" in
  *.jpg|*.jpeg|*.png|*.gif) ;;
  *.heic) die "HEIC is not accepted by Meta. Convert to JPG first: sips -s format jpeg" ;;
  *) die "unsupported file type: $SRC (use jpg, png or gif)" ;;
esac

# Facebook rejects photos over 4MB, and warns PNGs over 1MB look pixelated.
BYTES=$(wc -c < "$SRC" | tr -d ' ')
if [ "$BYTES" -gt 4194304 ]; then
  die "$(basename "$SRC") is $((BYTES / 1024 / 1024))MB. Facebook's limit is 4MB."
fi

NAME="${2:-$(basename "$SRC")}"
# Spaces in a filename survive git but break naive URL use, so normalise them.
NAME="${NAME// /-}"

DATE_DIR="$(date +%Y-%m-%d)"
DEST_DIR="$REPO_DIR/images/$DATE_DIR"
mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST_DIR/$NAME"

cd "$REPO_DIR"
git add "images/$DATE_DIR/$NAME"
if git diff --cached --quiet; then
  echo "No change, that exact image is already published." >&2
else
  git -c user.name="Aaron Malong" -c user.email="aaron.malong@gmail.com" \
      commit -qm "Publish $DATE_DIR/$NAME"
  git push -q origin main
fi

URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/images/$DATE_DIR/$NAME"

# raw.githubusercontent serves from a CDN that can lag a few seconds behind a push.
# Confirm the URL actually resolves before handing it to Meta, which caches failures.
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  CODE=$(curl -s -o /dev/null -w '%{http_code}' -L "$URL" || true)
  [ "$CODE" = "200" ] && break
  sleep 2
done

if [ "${CODE:-}" != "200" ]; then
  die "pushed, but $URL still returns HTTP ${CODE:-no response}. Do not use it yet."
fi

echo "$URL"
