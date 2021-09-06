#!/bin/sh

_filter="$1"

set -e -u

_arguments=""

for _origin in $(zfs list -H -o name -t snap | sort | grep -F "${_filter}"); do
    _comment=""
    _arguments="${_arguments} ${_origin} \"${_comment}\" off"
done

lines=$(($(tput lines) - 6))
columns=$(($(tput cols) - 20))

_output=$(mktemp /tmp/XXXXXX)

eval dialog --no-shadow --checklist \"Remove snapshots:\" $lines $columns $lines ${_arguments} 2>${_output}

echo

if [ -s "${_output}" ]; then
    for _snapshot in $(cat ${_output}); do
        eval zfs destroy -v ${_snapshot}
    done
fi

rm -f ${_output}
