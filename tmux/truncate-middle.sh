#!/bin/sh
n="$1"; max="${2:-35}"

# Strip noise prefixes before measuring. The list lives in the work submodule
prefixes="$(cd -P "$(dirname "$0")" && pwd)/../work/tmux/strip-prefixes"
if [ -r "$prefixes" ]; then
  best=""
  while IFS= read -r p || [ -n "$p" ]; do
    case $p in ''|'#'*) continue ;; esac
    case $n in "$p"*) [ ${#p} -gt ${#best} ] && best="$p" ;; esac
  done < "$prefixes"
  # Longest match wins; never strip a name down to nothing.
  [ -n "$best" ] && [ ${#best} -lt ${#n} ] && n="${n#"$best"}"
fi

[ ${#n} -le $max ] && printf '%s' "$n" && exit
side=$(( (max - 3) / 2 ))
printf '%s…%s' "${n:0:$side}" "${n:${#n}-$side}"
