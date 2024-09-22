# -*- mode: sh -*-

BSDKIT_YAML_INCLUDED="yes"

yaml-set() {
    if [ $# -ne 3 ]; then
        usage "yaml-set <file> <key> <value>"
    fi

    local _file=$1
    local _key=$2
    local _value=$3

    if [ ! -e ${_file} ]; then
        touch ${_file}
    fi

    yq -i eval "(.${_key}) = \"${_value}\"" ${_file}
}

yaml-get() {
    if [ $# -ne 2 ]; then
        usage "yaml-get <file> <key>"
    fi

    local _file=$1
    local _key=$2

    if [ ! -e ${_file} ]; then
        error "yaml-get: ${_file} does not exists"
    fi

    yq eval ".${_key}" ${_file}
}

yaml-del() {
    if [ $# -ne 2 ]; then
        usage "yaml-del <file> <key>"
    fi

    local _file=$1
    local _key=$2

    if [ ! -e ${_file} ]; then
        error "yaml-del: ${_file} does not exists"
    fi

    yq -i eval "del(.${_key})" ${_file}
}

yaml-add() {
    if [ $# -ne 3 ]; then
        usage "yaml-add <file> <key> <value>"
    fi

    local _file=$1
    local _key=$2
    local _value=$3

    if [ ! -e ${_file} ]; then
        touch ${_file}
    fi

    yq eval ".${_key}[] | select(. == \"${_value}\")" ${_file}

    if ! yq eval ".${_key}[] | select(. == \"${_value}\")" ${_file} | grep -q -e .; then
        yq -i eval ".${_key} += [\"${_value}\"]" ${_file}
    fi
}

yaml-remove() {
    if [ $# -ne 3 ]; then
        usage "yaml-remove <file> <key> <value>"
    fi

    local _file=$1
    local _key=$2
    local _value=$3

    if [ ! -e ${_file} ]; then
        touch ${_file}
    fi

    yq -i eval "del(.${_key}[] | select(. == \"${_value}\"))" ${_file}
}

yaml-list-keys() {
    if [ $# -ne 1 ]; then
        usage "yaml-list-keys <file>"
    fi

    local _file=$1

    if [ ! -e ${_file} ]; then
        error "yaml-list-keys: ${_file} does not exists"
    fi

    if [ ! -e ${BSDKIT_SRCDIR}/libexec/update-yaml.py ]; then
        error "yaml-list-keys: ${BSDKIT_SRCDIR}/libexec/update-yaml.py does not exists"
    fi

    python3 ${BSDKIT_SRCDIR}/libexec/update-yaml.py list-keys ${_file}
}

yaml-list-items() {
    if [ $# -ne 1 ]; then
        usage "yaml-list-items <file>"
    fi

    local _file=$1

    if [ ! -e ${_file} ]; then
        error "yaml-list-items: ${_file} does not exists"
    fi

    if [ ! -e ${BSDKIT_SRCDIR}/libexec/update-yaml.py ]; then
        error "yaml-list-items: ${BSDKIT_SRCDIR}/libexec/update-yaml.py does not exists"
    fi

    python3 ${BSDKIT_SRCDIR}/libexec/update-yaml.py list-items ${_file}
}
