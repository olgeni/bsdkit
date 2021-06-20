#!/bin/sh

set -e -u

_f1=$(mktemp /tmp/XXXXXX)

pkg query -e "%?r == 0" "%o" | sort -u > ${_f1}


eval pkg delete $(cat ${_f1} | fzf --multi --height=50%)

rm -f ${_f1}
