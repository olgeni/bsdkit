# -*- mode: sh -*-

BSDKIT_SYSTEM_INCLUDED="yes"

is-bios() {
    # Return 0 if the system is booted in BIOS mode
    [ "$(sysctl -n machdep.bootmethod)" = "BIOS" ]
}

is-efi() {
    # Return 0 if the system is booted in UEFI mode
    [ "$(sysctl -n machdep.bootmethod)" = "UEFI" ]
}

platform-is-digitalocean() {
    [ "$(kenv -q smbios.system.product)" = "Droplet" ]
}

platform-is-cloudsigma() {
    [ "$(kenv -q smbios.system.product)" = "CloudSigma" ]
}

platform-is-virtualbox() {
    [ "$(kenv -q smbios.system.product)" = "VirtualBox" ]
}

platform-is-vmware() {
    [ "$(kenv -q smbios.system.product)" = "VMware Virtual Platform" ]
}

platform-is-aws() {
    [ "$(kenv -q smbios.bios.vendor)" = "Amazon EC2" ]
}

platform-is-cloud() {
    platform-is-digitalocean || platform-is-cloudsigma || platform-is-virtualbox || platform-is-vmware || platform-is-aws
}

get-inet-address() {
    ifconfig $(get-gateway-interface) | awk '$1 == "inet" { print $2; exit }'
}

get-gateway-interface() {
    netstat --libxo json -n -r | jq -r '.["statistics"]["route-information"]["route-table"]["rt-family"][] | select(.["address-family"] == "Internet") | .["rt-entry"][] | select(.["destination"] == "default") | .["interface-name"]'
}

get-gateway-address() {
    netstat --libxo json -n -r | jq -r '.["statistics"]["route-information"]["route-table"]["rt-family"][] | select(.["address-family"] == "Internet") | .["rt-entry"][] | select(.["destination"] == "default") | .["gateway"]'
}

is-mount-point() {
    local _directory="${1%/}"

    mount -p | awk '{ print $2 }' | grep -q "^${_directory}\$"
}

get-os-version() {
    # FreeBSD 14.1-RELEASE-p4 -> 14.1
    local _destdir=${1:-/}

    ${_destdir}/usr/bin/uname -r | cut -d '-' -f 1
}

get-osrelease() {
    # FreeBSD 14.1-RELEASE-p4 -> 14.1-RELEASE-p4
    # kern.osrelease: 14.1-RELEASE-p4

    local _destdir=${1:-/}

    ${_destdir}/bin/freebsd-version -u
}

get-osreldate() {
    # FreeBSD 14.1-RELEASE-p4 -> 1401000
    # kern.osreldate: 1401000

    local _destdir=${1:-/}

    ${_destdir}/usr/bin/uname -K
}

get-src-osrelease() {
    # FreeBSD 14.1-RELEASE-p4 -> 14.1-RELEASE-p4
    local _srcdir=${1:-/usr/src}

    local _newvers_file="${_srcdir}/sys/conf/newvers.sh"
    local _release_name=""

    if [[ -f "${_newvers_file}" ]]; then
        local _contents=$(<"${_newvers_file}")

        local _revision=$(echo "${_contents}" | grep -oE 'REVISION="([^"]+)"' | cut -d'"' -f2)
        local _branch=$(echo "${_contents}" | grep -oE 'BRANCH="([^"]+)"' | cut -d'"' -f2)

        _release_name="${_revision}-${_branch}"
    else
        error "${_newvers_file} does not exist."
        return 1
    fi

    echo "${_release_name}"
}

get-src-osreldate() {
    # FreeBSD 14.1-RELEASE-p4 -> 1401000
    local _srcdir=${1:-/usr/src}

    local _param_file="${_srcdir}/sys/sys/param.h"

    if [ ! -f "${_param_file}" ]; then
        error "${_param_file} does not exist."
        return 1
    fi

    local _osreldate=$(awk '/#define __FreeBSD_version/ { print $3 }' "${_param_file}")

    if [ -z "${_osreldate}" ]; then
        error "String __FreeBSD_version not found in ${_param_file}"
        return 1
    fi

    echo "${_osreldate}"
}

get-src-major-version() {
    # FreeBSD 14.1-RELEASE-p4 -> 14
    local _src_dir=${1:-/usr/src}

    if [ ! -d "${_src_dir}" ]; then
        error "Source directory not found: ${_src_dir}"
        return 1
    fi

    local _newvers_sh=${_src_dir}/sys/conf/newvers.sh

    if [ ! -f "${_newvers_sh}" ]; then
        error "newvers.sh not found: ${_newvers_sh}"
        return 1
    fi

    local _revision

    while IFS= read -r line; do
        case "$line" in
            REVISION=*)
                _revision="${line#REVISION=\"}"
                _revision="${_revision%\"}"
                ;;
        esac
    done < <(grep -E '^REVISION=' "$_newvers_sh")

    local major_version="${_revision%%.*}"

    echo "${major_version}"
}

get-src-minor-version() {
    # FreeBSD 14.1-RELEASE-p4 -> 14.1
    local _src_dir=${1:-/usr/src}

    if [ ! -d "${_src_dir}" ]; then
        error "Source directory not found: ${_src_dir}"
        return 1
    fi

    local _newvers_sh=${_src_dir}/sys/conf/newvers.sh

    if [ ! -f "${_newvers_sh}" ]; then
        error "newvers.sh not found: ${_newvers_sh}"
        return 1
    fi

    local _revision

    while IFS= read -r line; do
        case "$line" in
            REVISION=*)
                _revision="${line#REVISION=\"}"
                _revision="${_revision%\"}"
                ;;
        esac
    done < <(grep -E '^REVISION=' "$_newvers_sh")

    echo "${_revision}"
}

get-src-patch-version() {
    # FreeBSD 14.1-RELEASE-p4 -> 14.1p4
    local _src_dir=${1:-/usr/src}

    if [ ! -d "${_src_dir}" ]; then
        error "Source directory not found: ${_src_dir}"
        return 1
    fi

    local _newvers_sh=${_src_dir}/sys/conf/newvers.sh

    if [ ! -f "${_newvers_sh}" ]; then
        error "newvers.sh not found: ${_newvers_sh}"
        return 1
    fi

    local _revision
    local _branch

    while IFS= read -r line; do
        case "$line" in
            REVISION=*)
                _revision="${line#REVISION=\"}"
                _revision="${_revision%\"}"
                ;;
            BRANCH=*)
                _branch="${line#BRANCH=\"}"
                _branch="${_branch%\"}"
                ;;
        esac
    done < <(grep -E '^(REVISION|BRANCH)=' "$_newvers_sh")

    if [[ "${_branch}" == RELEASE* ]]; then
        local version_number="${_revision}${_branch#RELEASE-}"
    else
        local version_number="${_revision}"
    fi

    echo "${version_number}"
}


get-file-fs() {
    local _directory="$1"

    df --libxo=json -T ${_directory} | jq -r '.["storage-system-information"].filesystem[] | .type'
}

is-file-on-fs() {
    local _directory="$1"
    local _type="$2"

    [ "$(get-file-fs ${_directory})" = "${_type}" ]
}

is-file-on-ufs() {
    local _directory="$1"

    is-file-on-fs ${_directory} "ufs"
}

is-file-on-zfs() {
    local _directory="$1"

    is-file-on-fs ${_directory} "zfs"
}

get-boot-pool() {
    zpool get -H -o name,value bootfs | awk '$2 != "-" { print $1 }'
}

get-ruby-version() {
    if whence -p ruby > /dev/null 2>&1; then
        ruby --version | awk '{ print $2 }' | cut -d '.' -f 1-2
    fi
}

get-perl-version() {
    if whence -p perl > /dev/null 2>&1; then
        perl -e 'print(sprintf("%d.%d\n", $^V->{version}[0], $^V->{version}[1]))'
    fi
}
