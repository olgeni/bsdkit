#!/bin/sh

set -e -u

_f1=$(mktemp /tmp/XXXXXX)
_f2=$(mktemp /tmp/XXXXXX)

pkg search -g -o \* | awk '{ print $1 }' | sort -u > ${_f1}
pkg info -qoa | sort -u > ${_f2}

_arguments=""

for _origin in `comm -23 ${_f1} ${_f2}`; do
    # _comment="`pkg rquery -U -i "%c" ${_origin} | head -n1 | cut -b1-50`"
    _comment=""
    _arguments="${_arguments} ${_origin} \"${_comment}\" off"
done

rm -f ${_f1} ${_f2}

lines=$(($(tput lines) - 6))
columns=$(($(tput cols) - 20))

_output=$(mktemp /tmp/XXXXXX)

eval dialog --no-shadow --checklist \"Available packages:\" $lines $columns $lines ${_arguments} 2>${_output}

clear

if [ -s "${_output}" ]; then
    eval pkg install $(cat ${_output})
fi

rm -f ${_output}
