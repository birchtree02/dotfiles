#!/bin/sh
# Copy text to a tmux buffer and, via `load-buffer -w`, out to the local
# clipboard over OSC 52 (see set-clipboard external in tmux.conf). This reaches
# the local clipboard over ssh/mosh with no local clipboard tool required.
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

# load-buffer -w sets the tmux buffer (so paste-buffer works) and forwards the
# text to the local clipboard via OSC 52.
printf '%s' "$text" | tmux load-buffer -w -
tmux display-message "copied: $text"
