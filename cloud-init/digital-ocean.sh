#!/bin/sh

set -e -u -x

exec >/tmp/cloud-init.log 2>&1

: ${BSDKIT_BRANCH:="master"}
: ${BSDKIT_VERSION:="12.1"}
: ${BSDKIT_JAIL_NETWORK:="172.16.1.0/24"}

cd /root

mv -v /boot/loader.conf.local /boot/.loader.conf

sed -i -e "/vfs\.root\.mountfrom/d;"        /boot/.loader.conf
sed -i -e "/vfs\.zfs\.vdev\.cache\.size/d;" /boot/.loader.conf
sed -i -e "/vfs\.zfs\.arc_max/d;"           /boot/.loader.conf

cat -s /boot/.loader.conf > /boot/loader.conf
rm -f -v /boot/.loader.conf

if kenv zfs_be_root >/dev/null 2>&1; then
    _zfs_pool=$(kenv zfs_be_root | sed "s@/.*@@")

    zfs create -o mountpoint=/jails ${_zfs_pool}/jails
    zfs create -o canmount=off      ${_zfs_pool}/usr/local
fi

zfs destroy -r ${_zfs_pool}@base_installation || :
zfs destroy -r ${_zfs_pool}@digitalocean_installation || :

mkdir -p /usr/local/etc/pkg/repos
pkg install -y pkg
echo 'bsdkit: { url: "https://olgeni.olgeni.com/FreeBSD/packages-${ABI}-default-nox11" }' > /usr/local/etc/pkg/repos/bsdkit.conf
pkg update -f
pkg upgrade -y
pkg install -y git pv py37-ansible
git clone https://github.com/olgeni/bsdkit.git
cd bsdkit
git checkout ${BSDKIT_BRANCH}
ansible-playbook --connection=local --inventory 127.0.0.1, -e ansible_python_interpreter=/usr/local/bin/python3 playbook/bsdkit.yml
pkg autoremove -y

if route get default | grep "interface:" >/dev/null 2>&1; then
    _iface=$(route get default | awk '/interface:/ { print $2 }')
    echo "nat on ${_iface} from ${BSDKIT_JAIL_NETWORK} to any -> egress" > /etc/pf.conf
    service pf enable
    service pf start
fi

./bsdkit-upgrade -v${BSDKIT_VERSION} -F
./bsdkit-upgrade -v${BSDKIT_VERSION}
rm -r -f /usr/freebsd-dist/
cd /root

rm /var/log/messages
newsyslog -C -v

exec >/dev/tty 2>&1
