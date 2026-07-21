#!/bin/sh
# Copy $1 to the system clipboard and a tmux buffer, then flash a status
# message. Portable across macOS (pbcopy) and Linux (wl-copy / xclip / xsel).
text="$1"
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
