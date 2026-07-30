#!/usr/bin/env bash
#
# toggle-theme.sh — flip between catppuccin mocha and latte, then live-reload
# tmux and any running nvim instances.
#
# The flavour is stored in ~/.local/state/dotfiles/theme; apply-state.sh turns
# that into the generated file tmux sources. kitty is not themed here — see the
# note further down.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/state.sh
. "$DOTFILES/scripts/lib/state.sh"

current="$(state_get theme "$DEFAULT_THEME")"
if [ "$current" = "latte" ]; then
  flavour="mocha"
else
  flavour="latte"
fi

"$DOTFILES/scripts/apply-state.sh" --theme "$flavour" >/dev/null

# kitty is intentionally not reloaded: its colours are pinned in kitty.conf
# because it won't repaint existing windows without remote control. tmux draws
# every themed surface (status bar, pane contents, pane borders) itself.

# tmux: reloading tmux.conf re-runs the source-file for the generated theme.
tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null || true

# nvim: retheme every running instance that exposes a server socket.
for sock in "${TMPDIR:-/tmp}"/nvim.*/*/nvim.*.0; do
  [ -S "$sock" ] || continue
  nvim --server "$sock" --remote-send "<Cmd>colorscheme catppuccin-$flavour<CR>" 2>/dev/null &
done
wait

echo "Switched to catppuccin-$flavour"
