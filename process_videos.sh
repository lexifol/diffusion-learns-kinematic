#!/usr/bin/env sh
set -eu

# ----- USER CONFIG -----
INPUT_DIR="videos_to_process"   # folder with your source videos
OUTPUT_DIR="static/videos"      # folder for outputs
x1=320                          # left (px)
y1=180                           # top  (px)
x2=1600                          # right (px)  <-- width = x2-x1
y2=1000                          # bottom(px)  <-- height = y2-y1
SPEED=3                         # 3x faster
CRF=23                          # quality: 18(best) .. 28(small). 23 is default
PRESET="medium"
# ------------------------

mkdir -p "$OUTPUT_DIR"

# compute width/height and force even numbers (required by libx264)
w=$(( x2 - x1 ))
h=$(( y2 - y1 ))
if [ $(( w % 2 )) -ne 0 ]; then w=$(( w - 1 )); fi
if [ $(( h % 2 )) -ne 0 ]; then h=$(( h - 1 )); fi

# quick ffmpeg check
if ! command -v ffmpeg >/dev/null 2>&1; then
  printf '%s\n' "Error: ffmpeg not found on PATH. Install ffmpeg and retry." >&2
  exit 2
fi

# process files
for infile in "$INPUT_DIR"/*; do
  [ -f "$infile" ] || continue

  # extension (lowercased)
  ext="${infile##*.}"
  ext="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
  case "$ext" in
    mp4|mov|avi|mkv|flv|webm) ;;
    *) continue ;;
  esac

  base="$(basename "$infile")"
  name="${base%.*}"
  outfile="$OUTPUT_DIR/${name}_proc.mp4"

  printf '%s\n' "Processing: $base -> $(basename "$outfile")"

  ffmpeg -hide_banner -y -i "$infile" \
    -vf "crop=${w}:${h}:${x1}:${y1},setpts=PTS/${SPEED}" \
    -an \
    -c:v libx264 -preset "$PRESET" -crf "$CRF" -pix_fmt yuv420p -movflags +faststart \
    "$outfile"
done

printf '%s\n' "Done."
