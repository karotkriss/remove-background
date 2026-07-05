---
name: remove-background
description: Remove the background from an image (or a whole folder of images), producing a transparent-background PNG cutout. Runs the rembg segmentation model locally and offline via uvx - no API key, no rate limits, no anti-bot, full resolution. Use whenever the user wants to remove, erase, delete, strip, or knock out an image background; cut out a subject; make a photo/logo/product background transparent; create a PNG cutout or sticker; or asks for remove.bg-style background removal.
---

# Remove image background (local, offline)

Removes the background from images using **rembg** (a U^2-Net ONNX model) entirely on this machine.
No API key, no network calls after the one-time model download, no rate limits, and it keeps full
resolution. This is the robust local alternative to the remove.bg website/API.

The output is always a **PNG with a transparent alpha channel** (the subject kept, the background
knocked out). Confirm success by checking the output exists and is mode `RGBA` with both transparent
and opaque pixels.

## The command

Everything runs through this single, self-contained invocation - no install step, no wrapper file
needed. Substitute the input/output paths:

```bash
# Single image -> transparent PNG
uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg i INPUT OUTPUT.png

# Whole folder (batch) -> folder of transparent PNGs
uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg p INPUT_DIR OUTPUT_DIR
```

`rembg` subcommands: `i` = single file, `p` = folder, `b` = byte stream, `d` = download models,
`s` = http server.

**Example:**

Input: `~/Downloads/product.jpg` (a product on a white studio background)
Command:
```bash
uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg i ~/Downloads/product.jpg ~/Downloads/product-nobg.png
```
Output: `~/Downloads/product-nobg.png` - the product on transparency.

## Options: finer edges and model choice

Flags go **before** the input/output paths:

```bash
# Alpha matting: softer, more accurate edges for hair, fur, fuzzy outlines. Slower.
uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg i -a INPUT OUTPUT.png

# Choose a model with -m:
#   u2net             (default) general purpose, good all-rounder
#   isnet-general-use          heavier, often cleaner edges
#   u2net_human_seg            tuned for people / portraits
#   u2netp                     lightweight and faster, lower quality
uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg i -m isnet-general-use INPUT OUTPUT.png
```

Run `uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg i --help` for all flags.

## Why the invocation looks the way it does

Do not simplify it to a bare `uvx rembg` - it will fail. The reasons:

- **`--python 3.11` + `--with "numba>=0.59.1"`** is a required workaround. `rembg` depends on
  `pymatting` -> `numba`, and on Python 3.12/3.13 uvx otherwise backtracks to an ancient
  `numba 0.53` / `llvmlite 0.36` that only builds on Python <3.10 and fails here. Pinning Python 3.11
  and forcing a modern numba pulls prebuilt wheels and resolves cleanly.
- **`rembg[cpu,cli]`** adds the `onnxruntime` CPU backend and the file/folder CLI commands; plain
  `rembg` reports "onnxruntime backend not found" / "CLI dependencies not installed".
- **First run** downloads the model (~176 MB) to `~/.u2net/` and caches it; every run after is fast
  and fully offline.

## Requirements

`uv` / `uvx` on PATH is the only prerequisite - it fetches rembg and its dependencies on demand into
uv's cache. No global pip install, no API key.

## Optional: a reusable wrapper

If you expect to do this often, it is convenient (not required) to save a small wrapper that fills in
default output names and folder handling. This repo ships one at `scripts/remove-bg.sh` for anyone who
clones it; a single-file skill install does not include it, so the inline command above is the
canonical path.

## When NOT to use this

If the user specifically needs remove.bg's own cloud model output (e.g. to match it exactly on a paid
plan), that is the remove.bg HTTP API (`api.remove.bg`, needs a key) - a different path. This skill is
the local, key-free route that covers the vast majority of "remove the background" requests.
