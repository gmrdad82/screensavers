#!/usr/bin/env bash
# Uninstall: restore Omarchy's default screensaver launcher in hypridle.
#
#   HYPRIDLE_CONF=<path>  override the hypridle.conf location.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH="$REPO_DIR/bin/launch"
HYPRIDLE="${HYPRIDLE_CONF:-$HOME/.config/hypr/hypridle.conf}"

[[ -f $HYPRIDLE ]] || { echo "hypridle.conf not found at $HYPRIDLE" >&2; exit 1; }

if grep -qF "$LAUNCH" "$HYPRIDLE"; then
  sed -i "s#$LAUNCH#omarchy-launch-screensaver#g" "$HYPRIDLE"
  echo "Restored omarchy-launch-screensaver in $HYPRIDLE"
  if pgrep -x hypridle >/dev/null; then
    pkill -x hypridle 2>/dev/null || true
    (setsid hypridle >/dev/null 2>&1 &)
    echo "hypridle reloaded."
  fi
else
  echo "Not installed (no reference to $LAUNCH in $HYPRIDLE)."
fi
