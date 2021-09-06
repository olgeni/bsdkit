#!/bin/sh

set -e -u

if ! command -v fzf > /dev/null 2>&1; then
    error "required command missing (fzf)"
    # EX_UNAVAILABLE
    exit 69
fi

for _snapshot in $(zfs list -H -o name -t snap | sort | fzf --multi --height=50%); do
    eval zfs destroy -v ${_snapshot}
done
