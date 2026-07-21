#!/bin/sh
n="$1"; max="${2:-35}"
[ ${#n} -le $max ] && printf '%s' "$n" && exit
side=$(( (max - 3) / 2 ))
printf '%s…%s' "${n:0:$side}" "${n:${#n}-$side}"
