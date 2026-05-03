# -*- mode: sh -*-

BSDKIT_RUN_INCLUDED="yes"

_current_step=""

# Run a named build step, logging start/end timestamps and aborting via
# error() if the command exits non-zero.
run-step() {
    local step_name="$1"
    shift
    _current_step="${step_name}"
    message "[${step_name}] Starting: $(date "+%Y-%m-%d %H:%M:%S")"
    if "$@"; then
        message "[${step_name}] Completed: $(date "+%Y-%m-%d %H:%M:%S")"
        return 0
    else
        local rc=$?
        error "[${step_name}] FAILED (exit code ${rc}): $(date "+%Y-%m-%d %H:%M:%S")"
        return ${rc}
    fi
}
