#!/usr/bin/env bash
# Install: point hypridle's screensaver trigger at this repo's launcher.
# Idempotent. Backs up hypridle.conf once. Touches NOTHING in ~/.local/share/omarchy.
#
#   HYPRIDLE_CONF=<path>  override the hypridle.conf location (default ~/.config/hypr/hypridle.conf)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH="$REPO_DIR/bin/launch"
HYPRIDLE="${HYPRIDLE_CONF:-$HOME/.config/hypr/hypridle.conf}"

[[ -f $HYPRIDLE ]] || { echo "hypridle.conf not found at $HYPRIDLE" >&2; exit 1; }
chmod +x "$REPO_DIR"/bin/* "$REPO_DIR"/install.sh "$REPO_DIR"/uninstall.sh 2>/dev/null || true

if grep -qF "$LAUNCH" "$HYPRIDLE"; then
  echo "Already installed — hypridle on-timeout already points at:"
  echo "  $LAUNCH"
  exit 0
fi

if ! grep -qF 'omarchy-launch-screensaver' "$HYPRIDLE"; then
  echo "No 'omarchy-launch-screensaver' reference in $HYPRIDLE — nothing to replace." >&2
  echo "Add '$LAUNCH' to an on-timeout line manually, or restore the omarchy default first." >&2
  exit 1
fi

[[ -f "$HYPRIDLE.bak" ]] || cp "$HYPRIDLE" "$HYPRIDLE.bak"

echo "before: $(grep -nF 'omarchy-launch-screensaver' "$HYPRIDLE")"
sed -i "s#omarchy-launch-screensaver#$LAUNCH#g" "$HYPRIDLE"
echo "after:  $(grep -nF "$LAUNCH" "$HYPRIDLE")"

if pgrep -x hypridle >/dev/null; then
  pkill -x hypridle 2>/dev/null || true
  (setsid hypridle >/dev/null 2>&1 &)
  echo "hypridle reloaded."
fi

echo "Installed. Preview anytime with: $REPO_DIR/bin/gallery"
echo "Uninstall with: $REPO_DIR/uninstall.sh"
