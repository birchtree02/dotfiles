#!/usr/bin/env bash
# Relaunch Claude in a tmux-resurrect-restored pane, resuming the pane's
# ORIGINAL session when possible instead of just the newest one for the cwd.
#
# tmux-resurrect send-keys this script into each restored pane whose saved
# command matched `~claude` (see @resurrect-processes in tmux.conf). By the
# time it runs, resurrect has already replayed the pane's captured scrollback
# into the pane. Claude prints
#     Resume this session with:
#     claude --resume <uuid>
# when it exits, so if that hint was on screen at snapshot time it is now in
# our own pane's scrollback. We read it back via $TMUX_PANE and resume that
# exact session.
#
# Fallback: if no resume hint is found (e.g. Claude was mid-session when the
# snapshot was taken, so its interactive UI was showing rather than the exit
# hint), fall back to `claude --continue`, which reopens the most recent
# session for the pane's cwd -- the previous behaviour.

uuid_re='[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'

session=""
if [ -n "$TMUX_PANE" ]; then
	# -S - grabs the full scrollback (the hint may have scrolled off screen);
	# take the last match so we resume the most recently shown session.
	session="$(tmux capture-pane -p -S - -t "$TMUX_PANE" 2>/dev/null \
		| grep -oE "claude --resume $uuid_re" \
		| tail -n1 \
		| grep -oE "$uuid_re")"
fi

if [ -n "$session" ]; then
	claude --resume "$session"
else
	claude --continue
fi
