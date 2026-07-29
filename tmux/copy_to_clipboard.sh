#!/bin/sh
# Copy text to the system clipboard and a tmux buffer, then flash a status
# message. Portable across macOS (pbcopy) and Linux (wl-copy / xclip / xsel).
#
# Usage:
#   copy_to_clipboard.sh <text>                 copy a literal argument
#   copy_to_clipboard.sh --opt <pane> <name>    copy a per-pane tmux option
#
# The --opt form reads the value with `tmux show -pv`, which preserves embedded
# newlines exactly. Passing a multi-line value as a shell argument would break
# at the first newline, so multi-line commands must use --opt.
if [ "$1" = "--opt" ]; then
  text="$(tmux show -pv -t "$2" "$3")"
else
  text="$1"
fi
[ -z "$text" ] && exit 0

if command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$text" | pbcopy
elif [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$text" | wl-copy
elif command -v xclip >/dev/null 2>&1; then
  printf '%s' "$text" | xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  printf '%s' "$text" | xsel --clipboard --input
fi

# Always keep a tmux buffer too, so paste-buffer works even with no clipboard tool.
tmux set-buffer -- "$text"
tmux display-message "copied: $text"
