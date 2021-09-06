#!/bin/sh

set -e -u

_f1=$(mktemp /tmp/XXXXXX)

pkg query -e "%?r == 0" "%o" | sort -u > ${_f1}

_arguments=""

for _origin in `cat ${_f1}`; do
    _comment=""
    _arguments="${_arguments} ${_origin} \"${_comment}\" off"
done

rm -f ${_f1}

lines=$(($(tput lines) - 6))
columns=$(($(tput cols) - 20))

_output=$(mktemp /tmp/XXXXXX)

eval dialog --no-shadow --checklist \"Leaf packages:\" $lines $columns $lines ${_arguments} 2>${_output}

clear

if [ -s "${_output}" ]; then
    eval pkg delete $(cat ${_output})
fi

rm -f ${_output}
