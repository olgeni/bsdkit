# -*- mode: sh -*-

BSDKIT_POSTGRESQL_INCLUDED="yes"

# These helpers expect POSTGRES_USER and TEMPLATE_DATABASE to be set in
# the environment of the caller.

postgresql-is-running() {
    local _is_running=$(psql -U ${POSTGRES_USER} -d ${TEMPLATE_DATABASE} -c "SELECT 1;" -t -A)

    if [ "${_is_running}" = "1" ]; then
        return 0
    else
        return 1
    fi
}

postgresql-is-in-recovery() {
    local _in_recovery=$(psql -U ${POSTGRES_USER} -d ${TEMPLATE_DATABASE} -c "SELECT pg_is_in_recovery();" -t -A)

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
