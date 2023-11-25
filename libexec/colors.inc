BSDKIT_COLORS_INC_INCLUDED=1

whence -w colors >/dev/null || {
    autoload colors && colors
}

message() {
    _script_name="${SCRIPT_NAME:-console}"

    if [ -t 1 ]; then
        echo "${fg_bold[white]}[${_script_name}]${reset_color}${fg[cyan]} $*${reset_color}"
    else
        echo "[${_script_name}] $*"
    fi
}

warning() {
    _script_name="${SCRIPT_NAME:-console}"

    if [ -t 2 ]; then
        echo "${fg_bold[white]}[${_script_name}]${reset_color}${fg[yellow]} $*${reset_color}" >&2
    else
        echo "[${_script_name}] $*" >&2
    fi
}

error() {
    _script_name="${SCRIPT_NAME:-console}"

    if [ -t 2 ]; then
        echo "${fg_bold[white]}[${_script_name}]${reset_color}${fg_bold[red]} $*${reset_color}" >&2
    else
        echo "[${_script_name}] $*" >&2
    fi
    exit 1
}
