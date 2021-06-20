#!/bin/sh

set -e -u

for _snapshot in $(zfs list -H -o name -t snap | sort | fzf --multi --height=50%); do
    eval zfs destroy -v ${_snapshot}
done
