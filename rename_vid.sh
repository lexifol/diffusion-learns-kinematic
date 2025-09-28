#!/usr/bin/env bash
set -euo pipefail

DIR="static/videos"   # 👈 change this to your folder

for f in "$DIR"/IMG_*_proc.mp4; do
  [ -e "$f" ] || continue   # skip if no match

  base="$(basename "$f")"

  # Extract the number between IMG_ and _proc.mp4
  num="${base#IMG_}"
  num="${num%_proc.mp4}"

  # Compute i = num - 4358
  i=$(( num - 4358 ))

  new="$DIR/${i}.mp4"
  echo "Renaming $base -> $(basename "$new")"
  mv -n -- "$f" "$new"
done
