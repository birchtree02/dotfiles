#!/bin/sh

declare -r LINE_NUMBER_PANE_WIDTH=3
declare -r LINE_NUMBER_UPDATE_DELAY=0.1
declare -r COLOR_NUMBERS_RGB="101;112;161"
declare -r COLOR_ACTIVE_NUMBER_RGB="255;158;100"

open_line_number_split(){
    local self_path=$(realpath $0)
    local pane_id=$(tmux display-message -pF "#{pane_id}")
    local was_zoomed=$(tmux display-message -pF "#{window_zoomed_flag}")
    local origin_window=$(tmux display-message -pF "#{window_id}")

    pgrep -f "$self_path $pane_id" > /dev/null && return

    # In a zoomed pane, the side-split would have to fight zoom. Instead break
    # the pane out into a fresh window, gutter-split there, and on exit join
    # it back to the origin window and re-zoom.
    if [ "$was_zoomed" = "1" ]; then
        tmux break-pane -s "$pane_id"
    fi

    tmux split-window -h -l $LINE_NUMBER_PANE_WIDTH -b -t "$pane_id" \
        -e "WAS_ZOOMED=$was_zoomed" \
        -e "ORIGIN_WINDOW=$origin_window" \
        "$self_path $pane_id"
    tmux select-pane -t "$pane_id"
}

enter_copy_mode(){
    local target_pane=$1
    tmux copy-mode -t "$target_pane"
}

get_cursor_line(){
    local output=$(tmux display-message -pt "$target_pane" -F '#{copy_cursor_y}')
    echo "${output:-0}"
}

is_in_copy_mode(){
    local mode=$(tmux display-message -p -t "$target_pane" -F '#{pane_mode}')
    ! [ -z $mode ]
}

redraw_line_numbers(){
    local cursor_line=$1
    local lines=$(tput lines)

    clear

    printf "\e[38;2;$COLOR_NUMBERS_RGB;2m"
    seq $cursor_line -1 1
    printf "\e[0m"

    printf "\e[38;2;$COLOR_ACTIVE_NUMBER_RGB;1m 0\e[0m"

    if [ $lines -gt $(($cursor_line + 1)) ]; then
        echo
        printf "\e[38;2;$COLOR_NUMBERS_RGB;2m"
        seq 1 $(($lines - $cursor_line - 2))
        printf $((lines - $cursor_line - 1))
        printf "\e[0m"
    fi
}

update_loop(){
    local cursor_line=""
    local last_cursor_line="-1"

    while is_in_copy_mode; do
        cursor_line=$(get_cursor_line)

        if [ $cursor_line -ne $last_cursor_line ]; then
            redraw_line_numbers $cursor_line
            last_cursor_line=$cursor_line
        fi

        sleep $LINE_NUMBER_UPDATE_DELAY
    done
}

restore_pane_width(){
    local target_pane=$1
    tmux resize-pane -t "$target_pane" -L $(($LINE_NUMBER_PANE_WIDTH + 1))
}

restore_zoom(){
    local target_pane=$1
    if [ "${WAS_ZOOMED:-0}" = "1" ] && [ -n "${ORIGIN_WINDOW:-}" ]; then
        # Defer until this gutter pane has actually died — otherwise the
        # layout change from closing it immediately undoes the zoom.
        tmux run-shell -b "sleep 0.15; \
            tmux join-pane -s '$target_pane' -t '$ORIGIN_WINDOW'; \
            tmux resize-pane -Z -t '$target_pane'; \
            tmux select-window -t '$ORIGIN_WINDOW'"
    fi
}

main(){
    local target_pane=$1

    if [ -z $target_pane ]; then
        open_line_number_split
        exit 0
    else
        enter_copy_mode $target_pane
    fi

    update_loop
    restore_pane_width $target_pane
    restore_zoom $target_pane
}

main "$@"
