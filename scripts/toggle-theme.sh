#!/bin/bash
KITTY_DIR="$HOME/.config/kitty"
TMUX_DIR="$HOME/.config/tmux"

current=$(readlink "$KITTY_DIR/catppuccin.conf" 2>/dev/null)
if [[ "$current" == *latte* ]]; then
  flavor="mocha"
else
  flavor="latte"
fi

ln -sf "catppuccin-$flavor.conf" "$KITTY_DIR/catppuccin.conf"
ln -sf "catppuccin-$flavor.conf" "$TMUX_DIR/catppuccin.conf"

kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null
tmux source-file "$TMUX_DIR/tmux.conf" 2>/dev/null
for sock in "$TMPDIR"/nvim.*/*/nvim.*.0; do
  nvim --server "$sock" --remote-send "<Cmd>colorscheme catppuccin-$flavor<CR>" 2>/dev/null &
done
wait

echo "Switched to catppuccin-$flavor"
