#!/bin/sh
# Print the tmux pane's foreground command, seeing through wrapper terminals
# (e.g. kiro-cli-term) that allocate their own inner PTY.
#
# Approach: from the pane pid, descend until we find a shell whose foreground
# process group (tpgid) is a *different* pid — that's the real foreground
# command. Falls back to the shell name if nothing is in the foreground.
root=$1
[ -z "$root" ] && exit 0

# Snapshot pid/ppid/tpgid separately from full command line (which may contain
# arbitrary whitespace and would break column-based parsing).
tree=$(ps -A -o pid=,ppid=,tpgid=)

pid=$root
# Check tpgid at each level, walking down through wrapper shells as needed.
# On Linux the pane pid IS the shell, so we check it directly first.
# On macOS with kiro-cli-term the pane pid is a wrapper and we must descend.
for _ in 1 2 3 4 5; do
  tpgid=$(printf '%s\n' "$tree" | awk -v p="$pid" '$1==p {print $3; exit}')
  [ -n "$tpgid" ] && [ "$tpgid" != "0" ] && [ "$tpgid" != "-1" ] && [ "$tpgid" != "$pid" ] && {
    cmd=$(ps -o command= -p "$tpgid" 2>/dev/null)
    [ -n "$cmd" ] && { printf '%s\n' "$cmd"; exit 0; }
  }
  child=$(printf '%s\n' "$tree" | awk -v p="$pid" '$2==p {print $1; exit}')
  [ -z "$child" ] && break
  pid=$child
done

# Nothing distinct in foreground — report the deepest shell's own command.
ps -o command= -p "$pid" 2>/dev/null
