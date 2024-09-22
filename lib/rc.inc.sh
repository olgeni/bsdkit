# -*- mode: sh -*-

BSDKIT_RC_INCLUDED=1

rc-set() {
    if [ $# -ne 3 ]; then
        echo "usage: rc-set <file> <key> <value>" >&2
    fi

    local _file=$1
    local _key=$2
    local _value=$3

    if grep -E "^[[:space:]]*${_key}|#[[:space:]]*${_key}" ${_file} > /dev/null 2>&1; then
        sed -E -i '' -e "/^[[:space:]]*${_key}[[:space:]]*=[[:space:]]*/ c\\
${_key}=\"${_value}\"
/^[[:space:]]*#[[:space:]]*${_key}/ c\\
${_key}=\"${_value}\"
" ${_file}
    else
        echo "${_key}=\"${_value}\"" >> ${_file}
    fi
}

rc-delete() {
    if [ $# -ne 2 ]; then
        echo "usage: rc-delete <file> <key>" >&2
    fi

    local _file=$1
    local _key=$2

    [ -e ${_file} ] || return 0

    sed -E -i '' -e "/^[[:space:]]*${_key}[[:space:]]*=/d" ${_file}
}

rc-get() {
    if [ $# -ne 2 ]; then
        echo "usage: rc-get <file> <key>" >&2
    fi

    local _file=$1
    local _key=$2

    local _buffer
    _buffer="$(grep -E "^[[:space:]]*${_key}[[:space:]]*=" ${_file})"

    local _value1
    _value1=$(echo ${_buffer} | sed -E -e "s/[^=]*[[:space:]]*=//")

    local _value2
    _value2=$(expr ${_value1} : "\"\(.*\)\"")

    if [ -n ${_value2} ]; then
        echo ${_value2}
    else
        echo ${_value1}
    fi
}
