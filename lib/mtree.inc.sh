# -*- mode: sh -*-

BSDKIT_MTREE_INCLUDED="yes"

# Apply the standard FreeBSD mtree specs under the given destination
# directory. Skips specs whose target subtree does not exist (e.g. lib32,
# include, tests, debug).
apply-mtree() {
    local _destdir=${1:-/}

    message "Applying BSD.root.dist"
    mtree -ideU -N ${_destdir}/etc -f ${_destdir}/etc/mtree/BSD.root.dist -p ${_destdir}/

    message "Applying BSD.usr.dist"
    mtree -ideU -N ${_destdir}/etc -f ${_destdir}/etc/mtree/BSD.usr.dist -p ${_destdir}/usr

    message "Applying BSD.var.dist"
    mtree -ideU -N ${_destdir}/etc -f ${_destdir}/etc/mtree/BSD.var.dist -p ${_destdir}/var

    if [ -f ${_destdir}/etc/mtree/BSD.lib32.dist ]; then
        if [ -d ${_destdir}/usr/lib32 ]; then
            message "Applying BSD.lib32.dist"
            mtree -ideU -N ${_destdir}/etc -f ${_destdir}/etc/mtree/BSD.lib32.dist -p ${_destdir}/usr
        fi
    fi

    if [ -f ${_destdir}/etc/mtree/BSD.include.dist ]; then
        if [ -d ${_destdir}/usr/include ]; then
            message "Applying BSD.include.dist"
            mtree -ideU -N ${_destdir}/etc -f ${_destdir}/etc/mtree/BSD.include.dist -p ${_destdir}/usr/include
        fi
    fi

    if [ -f ${_destdir}/etc/mtree/BSD.sendmail.dist ]; then
        message "Applying BSD.sendmail.dist"
        mtree -ideU -N ${_destdir}/etc -f ${_destdir}/etc/mtree/BSD.sendmail.dist -p ${_destdir}/
    fi

    if [ -f ${_destdir}/etc/mtree/BSD.tests.dist ]; then
        if [ -d ${_destdir}/usr/tests ]; then
            message "Applying BSD.tests.dist"
            mtree -ideU -N ${_destdir}/etc -f ${_destdir}/etc/mtree/BSD.tests.dist -p ${_destdir}/usr/tests
        fi
    fi

    if [ -f ${_destdir}/etc/mtree/BSD.debug.dist ]; then
        if [ -d ${_destdir}/usr/lib/debug ]; then
            message "Applying BSD.debug.dist"
            mtree -ideU -N ${_destdir}/etc -f ${_destdir}/etc/mtree/BSD.debug.dist -p ${_destdir}/usr/lib
        fi
    fi
}
