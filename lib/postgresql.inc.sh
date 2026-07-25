# -*- mode: sh -*-

BSDKIT_POSTGRESQL_INCLUDED="yes"

# These helpers expect POSTGRES_USER and TEMPLATE_DATABASE to be set in
# the environment of the caller, and error() from colors.inc.sh.

# Ask the data directory rather than the network. The socket directory and the
# port come from postgresql.conf, so a probe that connects to libpq's default
# socket reports a cluster listening anywhere else as stopped, which is the
# dangerous direction for a caller that is about to overwrite it. pg_ctl reads
# postmaster.pid: no socket, no port, no authentication, and nothing on stderr
# for the stopped case that callers normally expect.
postgresql-is-running() {
    local _bindir="$1"
    local _libdir="$2"
    local _directory="$3"
    local _status=0

    su ${POSTGRES_USER} -c "LD_LIBRARY_PATH=${_libdir} ${_bindir}/pg_ctl status -D ${_directory}" \
        >/dev/null 2>&1 || _status=$?

    case ${_status} in
        0) return 0 ;;
        3) return 1 ;;
        *) error "Cannot determine the state of the cluster in ${_directory} (pg_ctl exited with ${_status})." ;;
    esac
}

postgresql-is-in-recovery() {
    local _in_recovery=$(psql -U ${POSTGRES_USER} -d ${TEMPLATE_DATABASE} -c "SELECT pg_is_in_recovery();" -t -A 2>/dev/null)

    [ "${_in_recovery}" = "t" ]
}

postgresql-has-standby-signal() {
    local _directory="$1"

    [ -f "${_directory}/standby.signal" ]
}

postgresql-is-main() {
    local _directory="$1"

    ! postgresql-has-standby-signal "${_directory}"
}
