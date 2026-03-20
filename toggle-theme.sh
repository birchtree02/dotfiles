#!/bin/zsh
THEME_FILE="$HOME/.theme"
KITTY_DIR="$HOME/.config/kitty"
current=$(cat "$THEME_FILE" 2>/dev/null || echo "dark")

if [[ "$current" == "dark" ]]; then
  new="light"
  kitty_conf="catppuccin-latte.conf"
  tmux_bg="#eff1f5" tmux_fg="#4c4f69" tmux_s0="#ccd0da" tmux_s1="#bcc0cc" tmux_teal="#179299" tmux_blue="#1e66f5"
else
  new="dark"
  kitty_conf="catppuccin.conf"
  tmux_bg="#1e1e2e" tmux_fg="#cdd6f4" tmux_s0="#313244" tmux_s1="#45475a" tmux_teal="#94e2d5" tmux_blue="#89b4fa"
fi

echo "$new" > "$THEME_FILE"

# Kitty
ln -sf "$kitty_conf" "$KITTY_DIR/current-theme.conf"
kitty @ --to unix:/tmp/kitty set-colors -a -c "$KITTY_DIR/$kitty_conf" 2>/dev/null

# Tmux
tmux set -g @thm_bg "$tmux_bg" 2>/dev/null
tmux set -g @thm_fg "$tmux_fg" 2>/dev/null
tmux set -g @surface0 "$tmux_s0" 2>/dev/null
tmux set -g @surface1 "$tmux_s1" 2>/dev/null
tmux set -g @teal "$tmux_teal" 2>/dev/null
tmux set -g @blue "$tmux_blue" 2>/dev/null
tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null

