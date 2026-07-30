#!/bin/sh
# Machine-local state for these dotfiles: the catppuccin flavour used by tmux
# and nvim, and whether kitty padding is suppressed.
#
# State lives outside the repo so toggling a theme or padding never shows up as
# a git change, and so the choice stays per-machine instead of syncing between
# hosts.
#
# The directory is the XDG default written out literally rather than read from
# $XDG_STATE_HOME. kitty.conf and tmux.conf have to point at this directory with
# a fixed path, and their config-load environment does not reliably carry the
# shell's exported variables; honouring the variable in the scripts only would
# let the two disagree about where state lives.
STATE_DIR="$HOME/.local/state/dotfiles"

# Values used when no state file exists yet.
DEFAULT_THEME="mocha"
DEFAULT_PADDING="on"

# state_get <name> <default> — print a state value, or the default if unset.
state_get() {
  if [ -r "$STATE_DIR/$1" ]; then
    # Trailing newline stripped so callers can compare with = directly.
    tr -d '\n' <"$STATE_DIR/$1"
    echo
  else
    printf '%s\n' "$2"
  fi
}

# state_set <name> <value> — write a state file, creating the directory.
state_set() {
  mkdir -p "$STATE_DIR"
  printf '%s\n' "$2" >"$STATE_DIR/$1"
}
