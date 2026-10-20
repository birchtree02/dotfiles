#!/bin/sh
# Claude Code status line - inspired by Powerlevel10k Pure style
input=$(cat)
ESC=$(printf '\033')

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
in_tokens=$(echo "$input" | jq -r '.cost.total_input_tokens // empty')
out_tokens=$(echo "$input" | jq -r '.cost.total_output_tokens // empty')

# Shorten home directory to ~, then truncate middle to 30 chars
home="$HOME"
short_cwd="${cwd/#$home/~}"
if [ ${#short_cwd} -gt 30 ]; then
  side=$(( (30 - 3) / 2 ))
  short_cwd="${short_cwd:0:$side}…${short_cwd:${#short_cwd}-$side}"
fi

# Git branch + dirty marker
git_info=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  export GIT_OPTIONAL_LOCKS=0
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
      dirty="*"
    fi
    git_info=" ${ESC}[38;5;114m ${branch}${dirty}${ESC}[0m"
  fi
fi

# Context usage
ctx_info=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  ctx_info=" ${ESC}[38;5;242mctx:${used_int}%${ESC}[0m"
fi

# Cost + tokens
cost_info=""
if [ -n "$cost" ]; then
  cost_fmt=$(printf "%.2f" "$cost")
  tokens=""
  if [ -n "$in_tokens" ] && [ -n "$out_tokens" ]; then
    total=$((in_tokens + out_tokens))
    if [ "$total" -ge 1000000 ]; then
      tokens=$(printf " %.1fM" "$(echo "$total / 1000000" | bc -l)")
    elif [ "$total" -ge 1000 ]; then
      tokens=$(printf " %dk" "$((total / 1000))")
    else
      tokens=" ${total}"
    fi
  fi
  cost_info=" ${ESC}[38;5;242m\$${cost_fmt}${tokens}${ESC}[0m"
fi

# Parse model: split off "(... context)" suffix so we can merge with effort.
model_base="$model"
ctx_tier=""
case "$model" in
  *" ("*" context)"*)
    ctx_tier=$(printf '%s' "$model" | sed -n 's/.* (\([^)]*\) context).*/\1/p')
    model_base=$(printf '%s' "$model" | sed 's/ ([^)]* context)//')
    ;;
esac

model_suffix=""
if [ -n "$ctx_tier" ] && [ -n "$effort" ]; then
  model_suffix=" (${ctx_tier} ${effort})"
elif [ -n "$ctx_tier" ]; then
  model_suffix=" (${ctx_tier} context)"
elif [ -n "$effort" ]; then
  model_suffix=" [${effort}]"
fi

# Subscription usage: session (5h) and weekly (7d); omitted when absent
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
# resets_at as epoch seconds (accepts a number or an ISO-8601 string)
reset_epoch() {
  echo "$input" | jq -r --arg w "$1" '.rate_limits[$w].resets_at
    | if type == "number" then floor
      elif type == "string" then (sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601)
      else empty end' 2>/dev/null
}
five_reset=$(reset_epoch five_hour)
week_reset=$(reset_epoch seven_day)
now=$(date +%s)
# $4-cell bar of usage $1, with a thin white edge stroke at the elapsed share
# of a window of $3 seconds ending at epoch $2, drawn inside a cell (no gap)
bar() {
  pct=$(printf '%.0f' "$1")
  n=$4
  filled=$(( (pct * n + 50) / 100 )); [ "$filled" -gt "$n" ] && filled=$n
  mark=-1
  if [ -n "$2" ]; then
    left=$(( $2 - now )); [ "$left" -lt 0 ] && left=0; [ "$left" -gt "$3" ] && left=$3
    mark=$(( ( ($3 - left) * n + $3 / 2 ) / $3 ))
  fi
  b=""; i=0
  while [ $i -lt "$n" ]; do
    stroke=""
    [ $i -eq "$mark" ] && stroke="▏"
    [ $i -eq $((n - 1)) ] && [ "$mark" -eq "$n" ] && stroke="▕"
    # empty cells are solid dark blocks so the stroke's background matches them
    if [ $i -lt "$filled" ]; then shade=242; else shade=236; fi
    if [ -n "$stroke" ]; then
      b="${b}${ESC}[48;5;${shade}m${ESC}[38;5;255m${stroke}${ESC}[49m"
    else
      b="${b}${ESC}[38;5;${shade}m█"
    fi
    i=$((i + 1))
  done
  printf '%s' "${b}${ESC}[38;5;242m"
}
usage=""
# session bar is 2/3 the weekly one's width, with a leading dot
[ -n "$five_pct" ] && usage="· $(bar "$five_pct" "$five_reset" 18000 7)"
if [ -n "$week_pct" ]; then
  [ -n "$usage" ] && usage="$usage · "
  usage="${usage}$(bar "$week_pct" "$week_reset" 604800 10)"
fi
usage_info=""
[ -n "$usage" ] && usage_info=" ${ESC}[38;5;242m${usage}${ESC}[0m"

printf "${ESC}[38;5;75m%s${ESC}[0m%s ${ESC}[38;5;242m%s%s${ESC}[0m%s%s%s" \
  "$short_cwd" \
  "$git_info" \
  "$model_base" \
  "$model_suffix" \
  "$ctx_info" \
  "$cost_info" \
  "$usage_info"
