whence -w colors >/dev/null || {
    autoload colors && colors
}

message() {
    if [ -t 1 ]; then
        echo "${fg_bold[white]}[${SCRIPT_NAME}]${reset_color}${fg[cyan]} $*${reset_color}"
    else
        echo "[${SCRIPT_NAME}] $*"
    fi
}

error() {
    if [ -t 2 ]; then
        echo "${fg_bold[white]}[${SCRIPT_NAME}]${reset_color}${fg_bold[red]} $*${reset_color}" >&2
    else
        echo "[${SCRIPT_NAME}] $*" >&2
    fi
    exit 1
}
