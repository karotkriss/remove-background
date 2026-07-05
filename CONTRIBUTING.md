# Contributing to remove-background

Thank you for contributing. This repo publishes a single installable agent skill, `remove-background`,
that removes image backgrounds locally with rembg. This guide covers how to propose changes and the
conventions that keep the repository consistent.

## Getting started

- You need [`uv`](https://docs.astral.sh/uv/) / `uvx` on your `PATH` - that is the whole toolchain, the
  same thing the skill uses. No global installs.
- Try the skill's command directly to confirm your environment works:
  `uvx --python 3.11 --with "numba>=0.59.1" --from "rembg[cpu,cli]" rembg i some.jpg some-nobg.png`.
  The first run downloads the model (~176 MB) to `~/.u2net/`.
- Read [`AGENTS.md`](AGENTS.md) - it explains why the invocation is pinned the way it is, which is the
  one detail most changes touch.

## Making changes

- The skill must stay **self-contained in `skills/remove-background/SKILL.md`**, because `npx skills add`
  copies only that file. Never add a dependency on `scripts/remove-bg.sh` or any other repo file from
  within SKILL.md; the wrapper is a clone-only convenience.
- If you change the rembg command, update `SKILL.md`, `README.md`, and `AGENTS.md` together so they
  never disagree.
- **Verify end-to-end, not by inspection.** Run the changed command on a real image and confirm the
  output is a mode `RGBA` PNG with both fully transparent pixels (background gone) and opaque pixels
  (subject kept). A command that merely runs without error is not proof it removed the background.
- If you change the published skill, regenerate `skills-lock.json` with the `skills` CLI rather than
  hand-editing the `computedHash` - the hash is CLI-computed, not a plain file sha256.

## Commits

- Use Conventional Commits (feat, fix, docs, refactor, chore, ci, ...).
- Subject lines are imperative, lowercase after the type, no trailing period, around 50 characters.
- The body explains what and why, not how. Keep each commit atomic.

## Branches and pull requests

- Use short-lived feature branches off `main`, named `<type>-<description>` in lowercase kebab-case.
- Rebase onto `main` before opening a PR. Force-push only with `--force-with-lease`, never during an
  active review.
- Open a pull request against `main` with a clear description of what changed and how you verified it
  (include the end-to-end evidence for any command change).

## Reporting issues

Open a GitHub issue with your OS, `uv --version`, the exact command you ran, and what happened versus
what you expected. For a bad cutout, attach (or describe) the input image and the model you used.
