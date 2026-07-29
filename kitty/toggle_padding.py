import os


def main(args):
    pass


from kittens.tui.handler import result_handler

STATE_FILE = os.path.expanduser('~/.config/kitty/.padding_off')


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    off = os.path.exists(STATE_FILE)
    if off:
        os.remove(STATE_FILE)
        new_val = '7'
    else:
        open(STATE_FILE, 'w').close()
        new_val = '0'
    window = boss.window_id_map.get(target_window_id)
    boss.call_remote_control(window, ('set-spacing', f'padding={new_val}'))
