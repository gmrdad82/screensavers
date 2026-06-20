# Working agreement — PITO Screensavers

Authoritative, self-contained instructions for this repo. Keep it simple.

## What this repo is

A set of **PITO-logo terminal screensavers for Omarchy**. Each "variant" is a
piece of ASCII art (`art/NN-*.txt`) animated by **TerminalTextEffects (`tte`)**
with a pinned effect and a pinned color gradient. A one-line hook in the user's
`hypridle.conf` runs them on idle, replacing Omarchy's default — **without
touching anything inside `~/.local/share/omarchy`**, so `omarchy update` never
clobbers them.

## Layout

```
bin/run        # screensaver runtime: pick a variant, animate with tte, exit on input
bin/launch     # spawns bin/run fullscreen per-monitor (org.omarchy.screensaver class)
bin/preview    # render ONE variant in the current terminal — no system change
bin/gallery    # cycle ALL variants in the current terminal — no system change
bin/check      # sanity: bash -n + shellcheck + validate variants.conf
bin/record-gifs# regenerate the gallery GIFs (needs vhs) → assets/
art/NN-*.txt   # the ASCII arts (plain glyphs; tte supplies the color)
assets/*.gif   # animated previews of the hero variants (for the README)
variants.conf  # art|effect|extra_tte_args|label  (one line per variant)
install.sh     # patch hypridle on-timeout → bin/launch (idempotent, backs up .bak)
uninstall.sh   # restore omarchy-launch-screensaver
```

## How a variant is defined

One line in `variants.conf`, pipe-separated:

```
art/07-core-box.txt|matrix|--rain-color-gradient 00ff41 003b00 --final-gradient-stops 00ff41 dbffdb|Core Matrix
```

`extra_tte_args` is intentionally word-split into `tte` arguments. **Color comes
from the effect's gradient, not the art** — so always pin a gradient.

## Adding / changing a variant

1. Add `art/NN-name.txt` (plain glyphs, ≤ ~28 rows). Keep it recognizably PITO.
2. Add a `variants.conf` line. Pin `--final-gradient-stops` (and any effect color
   args) to **one hue or two adjacent hues — never a full rainbow spectrum.**
   Note: a few effects (e.g. `synthgrid`) have no `--final-gradient-stops`; use
   their own `--*-gradient-stops`. Verify flags with `tte <effect> --help`.
3. `./bin/check` must pass. `VARIANT=<n> ./bin/preview` to eyeball it.

## Conventions (do not break)

- **Pure bash.** No new runtime deps beyond `tte`, `hyprctl`, `jq` (already on
  Omarchy). Scripts must be `bash -n` clean and **shellcheck-clean** (`-x`).
- **`./bin/check` and CI must be green** before any commit. CI runs shellcheck +
  tte + `bin/check` on push/PR to `main`.
- **No system mutation outside `install.sh` / `uninstall.sh`.** `bin/preview`,
  `bin/gallery`, and `bin/run` (unmanaged) only draw in the current terminal.
- **Update-proof:** never edit or symlink files under `~/.local/share/omarchy`.
  The only out-of-repo change is the single `on-timeout` line in the user's
  `hypridle.conf`.
- **Branch `main`.** No new branches or tags unless asked.
- **License:** AGPL-3.0. Preserve `LICENSE` and `NOTICE`; modified/commercial use
  must credit gmrdad82.
- **Commits:** plain imperative messages. **Never mention Claude/AI in the
  author, committer, or message body, and never add a co-author trailer.**

## Commands

```
./bin/gallery                 # preview all variants (Ctrl-C to stop)
VARIANT=3 ./bin/preview 3     # preview one
./bin/check                   # sanity check
./install.sh                  # hook into hypridle (asks nothing; backs up .bak)
./uninstall.sh                # restore Omarchy default
```
