#!/usr/bin/env bash
# Uninstall: undo both hooks and restore Omarchy's default screensaver.
#   HYPRIDLE_CONF=<path>  override hypridle.conf  (default ~/.config/hypr/hypridle.conf)
#   UWSM_ENV=<path>       override uwsm env file  (default ~/.config/uwsm/env)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH="$REPO_DIR/bin/launch"
SHIM_DIR="$REPO_DIR/shim"
HYPRIDLE="${HYPRIDLE_CONF:-$HOME/.config/hypr/hypridle.conf}"
UWSM_ENV="${UWSM_ENV:-$HOME/.config/uwsm/env}"

# 1. Remove the PATH shim line(s) from uwsm env.
if [[ -f $UWSM_ENV ]] && grep -qF "$SHIM_DIR" "$UWSM_ENV"; then
  tmp="$(mktemp)"
  grep -vF -e "$SHIM_DIR" -e 'pito-screensavers: shadow omarchy-launch-screensaver' "$UWSM_ENV" >"$tmp"
  mv "$tmp" "$UWSM_ENV"
  echo "Removed PATH shim from $UWSM_ENV (relogin to apply)"
else
  echo "No PATH shim in $UWSM_ENV"
fi

# 2. Restore Omarchy's launcher in hypridle.
if [[ -f $HYPRIDLE ]] && grep -qF "$LAUNCH" "$HYPRIDLE"; then
  sed -i "s#$LAUNCH#omarchy-launch-screensaver#g" "$HYPRIDLE"
  echo "Restored omarchy-launch-screensaver in $HYPRIDLE"
  if pgrep -x hypridle >/dev/null; then
    pkill -x hypridle 2>/dev/null || true
    (setsid hypridle >/dev/null 2>&1 &)
    echo "hypridle reloaded"
  fi
else
  echo "hypridle not pointing at our launcher (nothing to restore)"
fi

echo "Uninstalled. The PATH shim symlink remains at $SHIM_DIR (harmless; delete the repo to remove)."
