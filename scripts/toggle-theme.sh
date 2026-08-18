#!/usr/bin/env bash
#
# toggle-theme.sh — flip between catppuccin mocha and latte, then live-reload
# kitty, tmux, nvim, claude, and zsh.
#
# The flavour is stored in ~/.local/state/dotfiles/theme; apply-state.sh turns
# that into the generated files each tool sources/includes.
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

# kitty: reload config so the padding/border area picks up the new background.
# This works without remote control — SIGUSR1 triggers a config re-read and
# kitty repaints the window chrome (background, cursor, borders). Cell colors
# are handled by tmux.
kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null || true

# tmux: reloading tmux.conf re-runs the source-file for the generated theme.
tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null || true

# nvim: retheme every running instance that exposes a server socket.
for sock in "${TMPDIR:-/tmp}"/nvim.*/*/nvim.*.0; do
  [ -S "$sock" ] || continue
  nvim --server "$sock" --remote-send "<Cmd>colorscheme catppuccin-$flavour<CR>" 2>/dev/null &
done
wait

# zsh: signal each registered interactive shell to re-source the palette. Only
# shells that installed the USR1 trap (see .zshrc) drop a pidfile here, so we
# never send USR1 — whose default action is terminate — to a shell that can't
# handle it. Stale pidfiles from crashed shells are pruned as we go.
pid_dir="$HOME/.local/state/dotfiles/zsh-pids"
if [ -d "$pid_dir" ]; then
  for pf in "$pid_dir"/*; do
    [ -e "$pf" ] || continue
    pid="${pf##*/}"
    if kill -0 "$pid" 2>/dev/null; then
      kill -USR1 "$pid" 2>/dev/null || true
    else
      rm -f "$pf"
    fi
  done
fi

echo "Switched to catppuccin-$flavour"
