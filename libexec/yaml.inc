yaml_set() {
    if [ $# -ne 3 ]; then
        usage "yaml_set <file> <key> <value>"
    fi

    __check_go_yq

    local _file=$1
    local _key=$2
    local _value=$3

    if [ ! -e ${_file} ]; then
        touch ${_file}
    fi

    yq -i eval "(.${_key}) = \"${_value}\"" ${_file}
}

yaml_get() {
    if [ $# -ne 2 ]; then
        usage "yaml_get <file> <key>"
    fi

    __check_go_yq

    local _file=$1
    local _key=$2

    if [ ! -e ${_file} ]; then
        error "yaml_get: ${_file} does not exists"
    fi

    yq eval ".${_key}" ${_file}
}

yaml_del() {
    if [ $# -ne 2 ]; then
        usage "yaml_del <file> <key>"
    fi

    __check_go_yq

    local _file=$1
    local _key=$2

    if [ ! -e ${_file} ]; then
        error "yaml_del: ${_file} does not exists"
    fi

    yq -i eval "del(.${_key})" ${_file}
}

yaml_list_keys() {
    if [ $# -ne 1 ]; then
        usage "yaml_list_keys <file>"
    fi

    __check_py_pyaml

    local _file=$1

    if [ ! -e ${_file} ]; then
        error "yaml_list_keys: ${_file} does not exists"
    fi

    python3 ${BSDKIT_SRCDIR}/libexec/update-yaml.py list-keys ${_file}
}

yaml_list_items() {
    if [ $# -ne 1 ]; then
        usage "yaml_list_items <file>"
    fi

    __check_py_pyaml

    local _file=$1

    if [ ! -e ${_file} ]; then
        error "yaml_list_items: ${_file} does not exists"
    fi

    python3 ${BSDKIT_SRCDIR}/libexec/update-yaml.py list-items ${_file}
}