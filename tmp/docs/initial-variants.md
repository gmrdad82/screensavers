# PITO Screensavers — initial design

This is the design record for the PITO screensaver variants and how the whole
thing hooks into Omarchy. The initial set was 20 concepts; 17 shipped (Core
Matrix, YouTube Burn, and Crumble Stone were cut during preview). Kept in the
repo for posterity; the living docs are `README.md` and `CLAUDE.md`.

## How Omarchy's screensaver works

On idle, `hypridle` runs `omarchy-launch-screensaver`, which spawns a borderless
terminal (classed `org.omarchy.screensaver`) on every monitor, each running
`omarchy-screensaver` → roughly:

```
tte -i ~/.config/omarchy/branding/screensaver.txt \
    --frame-rate 120 --canvas-width 0 --canvas-height 0 --reuse-canvas \
    --anchor-canvas c --anchor-text c --random-effect --no-eol --no-restore-cursor
```

There is **one** art file; variety comes from `tte`'s ~36 effects. **Color comes
from the effect's gradient, not the art** — so `--random-effect` produces
multi-hue ("rainbow") output. We avoid that by pinning a tasteful gradient per
variant.

## Architecture (this repo)

- **`art/NN-*.txt`** — 17 distinct PITO ASCII arts (plain glyphs).
- **`variants.conf`** — 20 lines, `art|effect|extra_tte_args|label`. The
  `extra_tte_args` carry the pinned `--final-gradient-stops` (single or adjacent
  hue, never a full spectrum).
- **`bin/run`** — fork of `omarchy-screensaver`: picks a random variant (or
  `$VARIANT`), runs `tte` with that variant's effect + gradient, mirrors
  Omarchy's cursor-hide / black-bg / exit-on-input loop.
- **`bin/launch`** — fork of `omarchy-launch-screensaver`: keeps the
  `org.omarchy.screensaver` window class + multi-monitor + terminal font config,
  but spawns `bin/run` instead of `omarchy-screensaver`.
- **`bin/preview` / `bin/gallery`** — render one / all variants in the current
  terminal. **They change nothing on the system.**
- **`install.sh`** — rewrites only the `on-timeout` line of
  `~/.config/hypr/hypridle.conf` to call `bin/launch`. **Touches no file inside
  `~/.local/share/omarchy`**, so `omarchy update` can never clobber it.
- **`uninstall.sh`** — restores the original `on-timeout` line.

## The 20 variants

Each has its own art, its own `tte` effect, and its own palette (one hue or two
adjacent hues — no rainbow). YouTube-red is a single hue and allowed.

| # | Label | Art | Effect | Gradient (hex) |
|---|---|---|---|---|
| 1 | Ice Beams | 01-wordmark-shadow | `beams` | `5170ff 89ddff` (fast) |
| 2 | Decrypt | 02-block-cursor | `decrypt` | `5170ff c0caff` |
| 3 | 3D Extrude | 03-3d-extrude | `slide` | `ffb454 ff8f40` |
| 4 | VHS Tracking | 04-vhs | `vhstape` | `7dcfff 2a3f5f` |
| 5 | Icon Bloom | 05-icon | `expand` | `00ff9c 1a6b4f` |
| 6 | Black Hole P | 06-p-monogram | `blackhole` | `bb9af7 7a3fd0` |
| 7 | Outline Rain | 07-outline | `rain` | `ffffff 565f89` |
| 8 | Tagline Swarm | 08-tagline | `swarm` | `5170ff 89ddff` |
| 9 | Pixel Pour | 09-pixel | `pour` | `ffd700 b8860b` |
| 10 | Glitch | 10-glitch | `unstable` | `ff5370 8a1f33` |
| 11 | Circuit Board | 11-circuit | `binarypath` | `00ff9c 005f3a` |
| 12 | Starfield Warp | 12-starfield | `scattered` | `89ddff 5170ff` |
| 13 | Wave Pool | 13-wave | `waves` | `5170ff bb9af7` |
| 14 | Fireworks | 14-fireworks | `fireworks` | `ffd700 ff8f40` |
| 15 | Bouncy Logo | 15-icon-small | `bouncyballs` | `7dcfff 5170ff` |
| 16 | Synthwave Grid | 16-synthgrid | `synthgrid` | `7a3fd0 bb9af7` (grid+text) |
| 17 | Spotlight Reveal | 17-spotlight | `spotlights` | `ffffff 7dcfff` |

## Adding a variant

1. Drop a new `art/NN-name.txt` (plain glyphs, ≤~28 rows).
2. Add a line to `variants.conf`: `art/NN-name.txt|<effect>|<extra tte args>|<Label>`.
   Pick a single-hue or adjacent-hue `--final-gradient-stops`.
3. `bin/check` to validate, `VARIANT=<n> bin/preview` to eyeball.

## Palette reference (PITO brand)

`pito-blue #5170ff` · `ice #89ddff` · `indigo #bb9af7` · `amber #ffb454` ·
`emerald #00ff9c` · `crimson #ff5370` · `steel #7dcfff` · `gold #ffd700` ·
`matrix-green #00ff41` · `youtube-red #ff0000` · `dim #565f89`.
