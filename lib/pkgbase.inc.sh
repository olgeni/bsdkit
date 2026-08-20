# -*- mode: sh -*-

BSDKIT_PKGBASE_INCLUDED="yes"

: ${BSDKIT_PKGBASE_REPO_FILE:="/usr/local/etc/pkg/repos/FreeBSD.conf"}
: ${BSDKIT_PKGBASE_SITE:="pkg+https://pkg.FreeBSD.org"}

get-pkgbase-abi() {
    # Build the pkg ABI for a target version, e.g. 15.1 -> FreeBSD:15:amd64
    #
    # The architecture field is taken from the running (or target) system
    # rather than constructed, because pkg's arch names do not always match
    # uname's (arm64 -> aarch64).

    local _version=$1
    local _destdir=${2:-}
    _destdir=${_destdir%/}

    local _major=${_version%%.*}

    local -a _pkg
    _pkg=(pkg)

    if [ -n "${_destdir}" ]; then
        _pkg=(pkg -r ${_destdir})
    fi

    local _abi=$(${_pkg[@]} config ABI) || return 1
    local _arch=${_abi##*:}

    echo "FreeBSD:${_major}:${_arch}"
}

get-pkgbase-repo-url() {
    # 15.1 -> pkg+https://pkg.FreeBSD.org/FreeBSD:15:amd64/base_release_1
    #
    # The ABI is written out literally rather than left as ${ABI}, and the
    # minor as base_release_N rather than ${VERSION_MINOR}, so the repository
    # is pinned to the target release instead of silently following whatever
    # the running system happens to be.

    local _version=$1
    local _destdir=${2:-}

    local _minor=${_version#*.}
    local _abi=$(get-pkgbase-abi ${_version} ${_destdir}) || return 1

    echo "${BSDKIT_PKGBASE_SITE}/${_abi}/base_release_${_minor}"
}

set-pkgbase-repo-url() {
    # Point the FreeBSD-base repository at a given URL, editing the existing
    # configuration file in place. Other repository blocks are preserved
    # byte-for-byte, and keys inside the FreeBSD-base block other than url
    # and enabled are kept.

    local _file=$1
    local _url=$2
    local _major=$3

    local _fingerprints="/usr/share/keys/pkgbase-${_major}"

    if [ ! -f "${_file}" ]; then
        mkdir -p "${_file:h}"

        cat > "${_file}" << EOF
FreeBSD-base: {
    mirror_type: "srv",
    signature_type: "fingerprints",
    fingerprints: "${_fingerprints}",
    url: "${_url}",
    enabled: yes
}
EOF
        return 0
    fi

    local _tmpfile=$(mktemp -t bsdkit-pkgbase.XXXXXX)

    awk -v url="${_url}" -v fingerprints="${_fingerprints}" '
        function flush_block(   i, n, entries, entry, key) {
            printf "FreeBSD-base: {\n"

            n = split(buffer, entries, /[,\n]/)

            for (i = 1; i <= n; i++) {
                entry = entries[i]
                gsub(/^[ \t]+|[ \t]+$/, "", entry)

                if (entry == "")
                    continue

                key = entry
                sub(/[ \t]*:.*$/, "", key)
                gsub(/"/, "", key)

                # url, enabled and fingerprints are all derived from the
                # target release, so they are regenerated rather than
                # carried over from whatever the file said before.
                if (key == "url" || key == "enabled" || key == "fingerprints")
                    continue

                seen_key[key] = 1
                printf "    %s,\n", entry
            }

            # The block must be self-contained: when pkg is pointed at a
            # repository directory with -R it does not merge with
            # /etc/pkg/FreeBSD.conf, so any key omitted here is simply lost.
            # Dropping signature_type/fingerprints would silently disable
            # signature verification.
            if (!("mirror_type" in seen_key))
                printf "    mirror_type: \"srv\",\n"

            if (!("signature_type" in seen_key))
                printf "    signature_type: \"fingerprints\",\n"

            printf "    fingerprints: \"%s\",\n", fingerprints

            printf "    url: \"%s\",\n", url
            printf "    enabled: yes\n"
            printf "}\n"
        }

        !inblock && !done && $0 ~ /^[ \t]*"?FreeBSD-base"?[ \t]*:/ {
            inblock = 1
            depth = 0
            seen = 0
            first = 1
            buffer = ""
        }

        inblock {
            opens = gsub(/\{/, "{")
            closes = gsub(/\}/, "}")

            depth += opens - closes

            if (opens > 0)
                seen = 1

            line = $0

            # On the opening line, drop everything up to and including the
            # brace, so the block name is not mistaken for a preserved entry.
            if (first) {
                sub(/^[^{]*\{/, "", line)
                first = 0
            }

            if (seen && depth <= 0) {
                sub(/\}[^}]*$/, "", line)
                buffer = buffer "\n" line

                flush_block()

                inblock = 0
                done = 1
                next
            }

            buffer = buffer "\n" line
            next
        }

        { print }

        END {
            if (!done) {
                buffer = ""
                flush_block()
            }
        }
    ' "${_file}" > ${_tmpfile} || { rm -f ${_tmpfile}; return 1 }

    cat ${_tmpfile} > "${_file}"
    rm -f ${_tmpfile}
}
