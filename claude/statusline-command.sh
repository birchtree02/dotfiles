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
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
      dirty="*"
    fi
    git_info=" ${ESC}[38;5;242m${branch}${dirty}${ESC}[0m"
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

printf "${ESC}[38;5;75m%s${ESC}[0m%s ${ESC}[38;5;242m%s%s${ESC}[0m%s%s" \
  "$short_cwd" \
  "$git_info" \
  "$model_base" \
  "$model_suffix" \
  "$ctx_info" \
  "$cost_info"
