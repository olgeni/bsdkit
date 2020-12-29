# Settings

    debug.ddb.textdump.pending=1
    kern.ipc.maxsockbuf=18874368 # for pacemaker/corosync
    kern.ipc.nmbclusters=65535
    kern.sched.preempt_thresh=224
    machdep.kdb_on_nmi=0
    net.inet.tcp.fast_finwait2_recycle=1
    net.inet.tcp.finwait2_timeout=30000
    net.inet.tcp.recvspace=8192
    net.inet.tcp.sendspace=8192
    net.inet.tcp.tso=0 # for pf in virtualized environments
    vfs.usermount=1
    vfs.zfs.prefetch_disable=1
    vfs.zfs.vdev.async_read_max_active=2
    vfs.zfs.vdev.async_read_min_active=1
    vfs.zfs.vdev.async_write_max_active=2
    vfs.zfs.vdev.async_write_min_active=1
    vfs.zfs.vdev.sync_read_max_active=2
    vfs.zfs.vdev.sync_read_min_active=1
    vfs.zfs.vdev.sync_write_max_active=2
    vfs.zfs.vdev.sync_write_min_active=1
    vm.pageout_update_period=0 # disable preventive swapping

# Tuning for faster resilver
    vfs.zfs.scrub_delay=0
    vfs.zfs.top_maxinflight=128
    vfs.zfs.resilver_min_time_ms=5000
    vfs.zfs.resilver_delay=0

# Reduce free space allocation

    vfs.zfs.spa_slop_shift=6

# Tune for mongodb client

    vm.max_wired=
