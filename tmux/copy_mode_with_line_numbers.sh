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
    # Capture the (unzoomed) layout and the pane-list order so the pane can be
    # restored to its exact original position on exit. Both are needed:
    # select-layout assigns panes to cells by LIST ORDER (not by the ids in the
    # layout string), and join-pane appends the returning pane to the end of the
    # list — so the order must be fixed up (via swap-pane) before select-layout.
    local origin_layout=$(tmux display-message -pF "#{window_layout}")
    local origin_panes=$(tmux list-panes -F "#{pane_id}" | tr '\n' ' ')

    pgrep -f "$self_path $pane_id" > /dev/null && return

    # In a zoomed pane, the side-split would have to fight zoom. Instead break
    # the pane out into a fresh window, gutter-split there, and on exit join
    # it back to the origin window, restore the layout, and re-zoom.
    if [ "$was_zoomed" = "1" ]; then
        tmux break-pane -s "$pane_id"
    fi

    tmux split-window -h -l $LINE_NUMBER_PANE_WIDTH -b -t "$pane_id" \
        -e "WAS_ZOOMED=$was_zoomed" \
        -e "ORIGIN_WINDOW=$origin_window" \
        -e "ORIGIN_LAYOUT=$origin_layout" \
        -e "ORIGIN_PANES=$origin_panes" \
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
        # Defer the whole restore until this gutter pane has actually died —
        # otherwise the layout change from closing it immediately undoes the
        # zoom. Runs the restore in a fresh invocation of this script (the loop
        # over panes is awkward to inline into a run-shell command string).
        # ORIGIN_PANES holds spaces, so it is passed as a single quoted arg.
        tmux run-shell -b "sleep 0.15; \
            '$0' --restore '$target_pane' '$ORIGIN_WINDOW' '$ORIGIN_LAYOUT' '$ORIGIN_PANES'"
    fi
}

restore_layout(){
    local target_pane=$1
    local origin_window=$2
    local origin_layout=$3
    local origin_panes=$4

    tmux join-pane -s "$target_pane" -t "$origin_window"

    # join-pane appended target to the end of the pane list; select-layout would
    # then assign panes to cells by that (wrong) order. Selection-sort the list
    # back to its original order with swap-pane before restoring the geometry.
    local i=0 want have
    for want in $origin_panes; do
        have=$(tmux list-panes -t "$origin_window" -F "#{pane_id}" | sed -n "$((i + 1))p")
        [ -n "$have" ] && [ "$have" != "$want" ] && tmux swap-pane -s "$want" -t "$have" 2>/dev/null
        i=$((i + 1))
    done

    tmux select-layout -t "$origin_window" "$origin_layout"
    tmux resize-pane -Z -t "$target_pane"
    tmux select-window -t "$origin_window"
}

main(){
    if [ "$1" = "--restore" ]; then
        shift
        restore_layout "$@"
        exit 0
    fi

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
