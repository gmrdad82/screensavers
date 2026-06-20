#!/usr/bin/env bash
# Install the PITO screensavers so they replace Omarchy's everywhere:
#   1. PATH shim     -> shadows `omarchy-launch-screensaver` for the Omarchy
#                       System menu + keybinds (effective at next login).
#   2. hypridle hook -> our launcher on idle (effective immediately).
# Idempotent and reversible. Touches ONLY user-owned files — nothing inside
# ~/.local/share/omarchy (so `omarchy update` is never affected).
#
#   HYPRIDLE_CONF=<path>  override hypridle.conf  (default ~/.config/hypr/hypridle.conf)
#   UWSM_ENV=<path>       override uwsm env file  (default ~/.config/uwsm/env)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH="$REPO_DIR/bin/launch"
SHIM_DIR="$REPO_DIR/shim"
HYPRIDLE="${HYPRIDLE_CONF:-$HOME/.config/hypr/hypridle.conf}"
UWSM_ENV="${UWSM_ENV:-$HOME/.config/uwsm/env}"
MARKER="# pito-screensavers: shadow omarchy-launch-screensaver (menu/keybind coverage)"

chmod +x "$REPO_DIR"/bin/* "$REPO_DIR"/install.sh "$REPO_DIR"/uninstall.sh 2>/dev/null || true

# --- 1. PATH shim: Omarchy menu (omarchy-menu) + keybinds call the bare command
#        `omarchy-launch-screensaver`. Prepending our shim dir to the session
#        PATH makes that resolve to our launcher — without touching Omarchy. ---
mkdir -p "$SHIM_DIR"
ln -sfn ../bin/launch "$SHIM_DIR/omarchy-launch-screensaver"
if [[ -f $UWSM_ENV ]]; then
  if grep -qF "$SHIM_DIR" "$UWSM_ENV"; then
    echo "PATH shim already present in $UWSM_ENV"
  else
    # shellcheck disable=SC2016  # $PATH must stay literal — it expands in the env file, not here
    printf '\n%s\nexport PATH="%s:$PATH"\n' "$MARKER" "$SHIM_DIR" >>"$UWSM_ENV"
    echo "Added PATH shim to $UWSM_ENV (menu/keybind coverage; effective at next login)"
  fi
else
  echo "note: $UWSM_ENV not found — skipping menu/keybind shim (idle hook still installed)"
fi

# --- 2. hypridle on-timeout: the idle trigger. Effective immediately. ---
if [[ -f $HYPRIDLE ]]; then
  if grep -qF "$LAUNCH" "$HYPRIDLE"; then
    echo "hypridle already points at $LAUNCH"
  elif grep -qF 'omarchy-launch-screensaver' "$HYPRIDLE"; then
    [[ -f "$HYPRIDLE.bak" ]] || cp "$HYPRIDLE" "$HYPRIDLE.bak"
    sed -i "s#omarchy-launch-screensaver#$LAUNCH#g" "$HYPRIDLE"
    echo "Patched hypridle on-timeout -> $LAUNCH"
    if pgrep -x hypridle >/dev/null; then
      pkill -x hypridle 2>/dev/null || true
      (setsid hypridle >/dev/null 2>&1 &)
      echo "hypridle reloaded"
    fi
  else
    echo "warning: no 'omarchy-launch-screensaver' line in $HYPRIDLE — idle hook unchanged"
  fi
else
  echo "note: $HYPRIDLE not found — skipping idle hook"
fi

echo
echo "Installed. Idle trigger works now; the Omarchy menu/keybinds pick it up"
echo "after you log out and back in (PATH changes need a fresh session)."
echo "Test immediately:  $LAUNCH force"
echo "Uninstall:         $REPO_DIR/uninstall.sh"
