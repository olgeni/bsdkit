#!/bin/sh

set -e -u

_f1=$(mktemp /tmp/XXXXXX)
_f2=$(mktemp /tmp/XXXXXX)

pkg search -g -o \* | awk '{ print $1 }' | sort -u > ${_f1}
pkg query -e "%?r == 0" "%o" | sort -u > ${_f2}

pkg delete $(comm -13 ${_f1} ${_f2} | fzf --multi --height=50%)

rm -f ${_f1} ${_f2}
