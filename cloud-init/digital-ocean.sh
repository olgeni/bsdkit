#!/bin/sh

set -e -u -x

exec > /var/log/bsdkit-cloud-init.log 2>&1

: "${BSDKIT_BRANCH:=master}"
: "${BSDKIT_VERSION:=12.1}"
: "${BSDKIT_JAIL_NETWORK:=172.16.1.0/24}"

cd /root

mv -v /boot/loader.conf.local /boot/.loader.conf

sed -i -e "/vfs\.root\.mountfrom/d;"        /boot/.loader.conf
sed -i -e "/vfs\.zfs\.vdev\.cache\.size/d;" /boot/.loader.conf
sed -i -e "/vfs\.zfs\.arc_max/d;"           /boot/.loader.conf

cat -s /boot/.loader.conf > /boot/loader.conf
rm -f -v /boot/.loader.conf

if kenv zfs_be_root > /dev/null 2>&1; then
    _zfs_pool=$(kenv zfs_be_root | sed "s@/.*@@")

    zfs create -o mountpoint=/jails "${_zfs_pool}"/jails
    zfs create -o canmount=off      "${_zfs_pool}"/usr/local
fi

zfs destroy -r "${_zfs_pool}"@base_installation || :
zfs destroy -r "${_zfs_pool}"@digitalocean_installation || :

mkdir -p /usr/local/etc/pkg/repos
pkg install -y pkg
# shellcheck disable=SC2016
echo 'bsdkit: { url: "https://olgeni.olgeni.com/FreeBSD/packages-${ABI}-default-nox11" }' > /usr/local/etc/pkg/repos/bsdkit.conf
pkg update -f
pkg upgrade -y
pkg install -y git pv py37-ansible
git clone https://github.com/olgeni/bsdkit.git
cd bsdkit
git checkout ${BSDKIT_BRANCH}
env BSDKIT_INSTALL_HOST=yes ansible-playbook --connection=local --inventory 127.0.0.1, -e ansible_python_interpreter=/usr/local/bin/python3 playbook/bsdkit.yml
pkg autoremove -y

if route get default | grep "interface:" > /dev/null 2>&1; then
    _iface=$(route get default | awk '/interface:/ { print $2 }')
    echo "nat on ${_iface} from ${BSDKIT_JAIL_NETWORK} to any -> egress" > /etc/pf.conf
    service pf enable
    service pf start
fi

sysrc -a -e > /etc/.rc.conf
cat /etc/.rc.conf > /etc/rc.conf
rm -f /etc/.rc.conf

sysrc -x cloudinit_enable || :
sysrc -x digitalocean || :
sysrc -x digitaloceanpre || :
sysrc -x ifconfig_vtnet0_ipv6 || :
sysrc -x ipv6_activate_all_interfaces || :
sysrc -x ipv6_defaultrouter || :

if sysrc -c route_net0; then
    sysrc -x route_net0
fi

rm -f /usr/local/etc/rc.d/digitalocean
rm -f /usr/local/etc/rc.d/digitaloceanpre

pkg delete -y net/cloud-init python2 python27 || :
pkg delete -y -g py27\* || :
pkg autoremove -y || :

./bsdkit-upgrade -v${BSDKIT_VERSION} -F
./bsdkit-upgrade -v${BSDKIT_VERSION} -n bsdkit
rm -r -f /usr/freebsd-dist/
cd /root

rm /var/log/messages
newsyslog -C -v

# _mnt=$(mktemp -d)
# bectl jail -b -o name=bsdkit -o mount.devfs=1 bsdkit ${_mnt}
# bectl ujail bsdkit
# rmdir ${_mnt}

exec > /dev/tty 2>&1
