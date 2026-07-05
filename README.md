# remove-background

A skill for Claude Code and compatible agents that removes the background from an image - or a whole
folder of images - and produces a transparent-background PNG cutout.
It runs the [rembg](https://github.com/danielgatis/rembg) segmentation model (U^2-Net, ONNX) entirely
on your own machine through `uvx`, so there is **no API key, no rate limits, no anti-bot friction, and
no resolution cap** - the robust local alternative to the remove.bg website or API.

Use it whenever you want to remove, erase, strip, or knock out an image background; cut out a subject;
make a photo, logo, or product background transparent; or create a PNG cutout or sticker.

## Installation

This is a skill for Claude Code and compatible agents.
The recommended way to install it is with the agentskills.io [`skills`](https://agentskills.io) CLI,
which fetches the skill from GitHub and wires it into your agent's skills directory.

### Install with the skills CLI (recommended)

```bash
npx skills add karotkriss/remove-background --skill remove-background
```

That installs the `remove-background` skill from `skills/remove-background/SKILL.md`, where compatible
agents discover it automatically.
Re-run the same command (or `npx skills update remove-background`) to update to the latest version, and
`npx skills remove remove-background` to remove it.

### Install by cloning (fallback)

If you would rather not use the skills CLI, copy the skill file straight into Claude Code's skills
directory:

```bash
mkdir -p ~/.claude/skills/remove-background
TMP=$(mktemp -d)
git clone https://github.com/karotkriss/remove-background.git "$TMP"
cp "$TMP/skills/remove-background/SKILL.md" ~/.claude/skills/remove-background/
```

## Requirements

- [`uv`](https://docs.astral.sh/uv/) / `uvx` on your `PATH`. That is the only prerequisite - it fetches
  rembg and its dependencies on demand into uv's cache. No global pip install and no API key.
- The first run downloads the model (~176 MB) to `~/.u2net/` and caches it; every run after is fast and
  fully offline.

## Usage

Once installed, just ask your agent naturally - "remove the background from photo.jpg", "cut out this
product on a transparent background", "make a sticker from logo.png". The skill also works directly from
a shell:

```bash
# Single image -> transparent PNG
uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg i input.jpg output.png

# Whole folder (batch)
uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg p ./images ./images-nobg
```

Finer edges (hair, fur) with alpha matting, or a different model:

```bash
uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg i -a input.jpg output.png
uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg i -m isnet-general-use input.jpg output.png
```

A convenience wrapper that fills in default output names and handles folders is included at
[`scripts/remove-bg.sh`](scripts/remove-bg.sh) for anyone who clones the repo:

```bash
bash scripts/remove-bg.sh photo.jpg            # -> photo-nobg.png
bash scripts/remove-bg.sh ./images ./out       # batch a folder
bash scripts/remove-bg.sh in.jpg out.png -- -a # pass extra rembg flags after --
```

## Why the invocation is pinned

Do not simplify it to a bare `uvx rembg` - it fails. `rembg` depends on `pymatting` -> `numba`, and on
Python 3.12/3.13 `uvx` otherwise backtracks to an ancient `numba 0.53` / `llvmlite 0.36` that only
builds on Python <3.10. Pinning `--python 3.11` and forcing `numba>=0.59.1` pulls prebuilt wheels and
resolves cleanly, and `rembg[cpu,cli]` adds the ONNX Runtime CPU backend plus the file/folder CLI
commands. The `SKILL.md` documents this so the skill stays maintainable.

## When not to use this

If you specifically need remove.bg's own cloud model output (for example to match it exactly on a paid
plan), reach for the remove.bg HTTP API (`api.remove.bg`, needs a key) instead. This skill is the
local, key-free route that covers the vast majority of background-removal needs.

## License

[MIT](LICENSE).
