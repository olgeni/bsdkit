#!/bin/sh

set -e -u

if ! command -v fzf > /dev/null 2>&1; then
    error "required command missing (fzf)"
    # EX_UNAVAILABLE
    exit 69
fi

_f1=$(mktemp /tmp/XXXXXX)
_f2=$(mktemp /tmp/XXXXXX)

pkg search -g -o \* | awk '{ print $1 }' | sort -u > ${_f1}
pkg info -qoa | sort -u > ${_f2}

pkg install $(comm -23 ${_f1} ${_f2} | fzf --multi --height=50%)

rm -f ${_f1} ${_f2}
