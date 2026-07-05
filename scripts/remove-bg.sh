#!/usr/bin/env bash
# remove-bg.sh - remove the background from image(s) using rembg, fully local and
# offline (no API key, no rate limits, full resolution). Outputs a transparent PNG.
#
# Usage:
#   remove-bg.sh <input-image> [output-image]      # single file
#   remove-bg.sh <input-folder> [output-folder]    # batch (whole folder)
#
# Pass extra rembg flags after a literal `--`, e.g.:
#   remove-bg.sh in.jpg out.png -- -a                     # alpha matting (finer hair/edges)
#   remove-bg.sh in.jpg out.png -- -m isnet-general-use   # a different/heavier model
#   remove-bg.sh in.jpg out.png -- -m u2net_human_seg     # tuned for people
#
# Defaults: single file -> "<input-basename>-nobg.png"; folder -> "<folder>-nobg/".
set -euo pipefail

if [ "$#" -lt 1 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

# rembg is run through uvx with a pinned toolchain: Python 3.11 + a modern numba.
# Why the pin: rembg -> pymatting -> numba, and uvx on Python 3.12/3.13 otherwise
# backtracks to an ancient numba 0.53 / llvmlite 0.36 that fails to build. Forcing
# numba>=0.59.1 on Python 3.11 pulls prebuilt wheels and resolves cleanly. The
# [cpu,cli] extras add the onnxruntime backend and the file/folder CLI commands.
# First run downloads the model (~176 MB) to ~/.u2net/ and caches it.
REMBG=(uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg)

# Split args at a literal `--`: before it is ours, after it passes through to rembg.
args=()
extra=()
after=0
for a in "$@"; do
  if [ "$after" -eq 1 ]; then extra+=("$a"); continue; fi
  if [ "$a" = "--" ]; then after=1; continue; fi
  args+=("$a")
done

in="${args[0]:-}"
out="${args[1]:-}"

if [ -z "$in" ]; then echo "error: no input given" >&2; exit 2; fi
if [ ! -e "$in" ]; then echo "error: input not found: $in" >&2; exit 1; fi

if [ -d "$in" ]; then
  out="${out:-${in%/}-nobg}"
  mkdir -p "$out"
  echo "Removing backgrounds (batch): '$in' -> '$out'" >&2
  "${REMBG[@]}" p ${extra[@]+"${extra[@]}"} "$in" "$out"
else
  if [ -z "$out" ]; then
    out="${in%.*}-nobg.png"
  fi
  # Ensure the output dir exists if the user gave a nested path.
  outdir="$(dirname -- "$out")"
  [ -n "$outdir" ] && mkdir -p "$outdir"
  echo "Removing background: '$in' -> '$out'" >&2
  "${REMBG[@]}" i ${extra[@]+"${extra[@]}"} "$in" "$out"
fi

echo "Done: $out" >&2
