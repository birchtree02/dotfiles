import os
import subprocess

from kittens.tui.handler import result_handler

# Machine-local state, shared with scripts/apply-state.sh. Written out literally
# rather than read from $XDG_STATE_HOME because kitty's environment at config
# load time does not reliably carry the shell's exported variables, and the two
# must agree on where state lives.
STATE_DIR = os.path.expanduser('~/.local/state/dotfiles')
PADDING_STATE = os.path.join(STATE_DIR, 'padding')
APPLY_STATE = os.path.expanduser('~/dotfiles/scripts/apply-state.sh')

# Kept in step with window_padding_width in kitty.conf.
PADDING_ON = '7'
PADDING_OFF = '0'


def main(args):
    pass


def _read_padding():
    try:
        with open(PADDING_STATE) as fh:
            value = fh.read().strip()
    except OSError:
        return 'on'
    return value if value in ('on', 'off') else 'on'


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    new_state = 'off' if _read_padding() == 'on' else 'on'
    width = PADDING_OFF if new_state == 'off' else PADDING_ON

    # Persist via apply-state.sh so the generated kitty conf is rewritten too;
    # that keeps newly created OS windows and a later config reload in agreement
    # with what we are about to apply live.
    try:
        subprocess.run(
            [APPLY_STATE, '--padding', new_state],
            check=True,
            capture_output=True,
        )
    except (OSError, subprocess.CalledProcessError):
        # Fall back to writing the state file directly so the toggle still
        # works if the repo isn't at ~/dotfiles on this machine.
        os.makedirs(STATE_DIR, exist_ok=True)
        with open(PADDING_STATE, 'w') as fh:
            fh.write(new_state + '\n')

    # --all --configured so every window changes and new windows inherit it,
    # matching what the regenerated config file now says.
    window = boss.window_id_map.get(target_window_id)
    boss.call_remote_control(
        window, ('set-spacing', '--all', '--configured', f'padding={width}')
    )
