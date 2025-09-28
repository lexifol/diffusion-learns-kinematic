#!/usr/bin/env bash
set -euo pipefail

DIR="static/videos"  # 👈 change to your folder

# Use a temporary folder to avoid name collisions
TMPDIR="$DIR/tmp_rename"
mkdir -p "$TMPDIR"

# Sort files numerically by current name (assumes names like 1.mp4, 3.mp4, etc.)
files=($(ls "$DIR"/*.mp4 | sort -V))

count=1
for f in "${files[@]}"; do
    ext="${f##*.}"
    tmp="$TMPDIR/$count.$ext"
    mv -- "$f" "$tmp"
    ((count++))
done

# Move back to original directory
mv "$TMPDIR"/* "$DIR"/
rmdir "$TMPDIR"

echo "Renaming complete: ${#files[@]} files renamed sequentially."
