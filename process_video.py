#!/usr/bin/env python3
"""
Batch process videos with ffmpeg (no MoviePy).
- Crops all videos to the same rectangle (CROP: x1,y1,x2,y2)
- Speeds video up by SPEED (setpts=PTS/SPEED)
- Removes audio (-an)
- Re-encodes with libx264 (CRF) and writes .mp4 outputs

Requires: ffmpeg on PATH
"""

import subprocess
from pathlib import Path
import sys

# ---------- CONFIG ----------
INPUT_DIR = Path("videos_to_process")
OUTPUT_DIR = Path("static/videos")
CROP_REGION = (0, 0, 1920, 1080)   # (x1, y1, x2, y2) - change to your values
SPEED = 3                           # speed-up factor (3 = 3x faster)
CRF = 23                            # 0 (lossless) .. 51 (worst). 18-28 is typical. Lower -> higher quality
PRESET = "medium"                   # ffmpeg preset: ultrafast|superfast|veryfast|faster|fast|medium|slow|slower|veryslow
PIX_FMT = "yuv420p"                 # safe for wide playback
OVERWRITE = True                    # True -> add -y to overwrite outputs
EXTENSIONS = {".mp4", ".mov", ".avi", ".mkv", ".flv", ".webm"}

# ---------- end config ----------

INPUT_DIR = INPUT_DIR.resolve()
OUTPUT_DIR = OUTPUT_DIR.resolve()
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def ffmpeg_ok():
    try:
        subprocess.run(["ffmpeg","-version"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        return True
    except Exception:
        return False

def process_file(in_path: Path):
    x1,y1,x2,y2 = CROP_REGION
    w = x2 - x1
    h = y2 - y1
    if w <= 0 or h <= 0:
        raise ValueError("Invalid crop region: width/height must be > 0")
    out_name = in_path.stem + "_proc.mp4"
    out_path = OUTPUT_DIR / out_name

    vf = "crop=1920:1080:0:0,setpts=PTS/3"
    cmd = [
        "ffmpeg",
    ]
    if OVERWRITE:
        cmd.append("-y")
    cmd += [
        "-hide_banner",
        "-i", str(in_path),
        "-vf", vf,
        "-an",                       # remove audio (mute)
        "-c:v", "libx264",
        "-preset", PRESET,
        "-crf", str(CRF),
        "-pix_fmt", PIX_FMT,
        str(out_path)
    ]

    print("Processing:", in_path.name, "->", out_path.name)
    print("Running:", " ".join(subprocess.list2cmdline([c]) for c in cmd))
    subprocess.run(cmd, check=True)

def main():
    if not ffmpeg_ok():
        print("Error: ffmpeg not found on PATH. Install ffmpeg and try again.")
        sys.exit(1)

    files = [p for p in INPUT_DIR.iterdir() if p.is_file() and p.suffix.lower() in EXTENSIONS]
    if not files:
        print("No video files found in", INPUT_DIR)
        return

    for p in sorted(files):
        try:
            process_file(p)
        except subprocess.CalledProcessError as e:
            print(f"ffmpeg failed on {p.name}: {e}")
        except Exception as e:
            print(f"Error processing {p.name}: {e}")

    print("Done.")

if __name__ == "__main__":
    main()
