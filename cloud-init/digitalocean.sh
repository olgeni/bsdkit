#!/bin/sh

set -e -u -x

exec > /var/log/bsdkit-cloud-init.log 2>&1

: "${BSDKIT_BRANCH:=master}"
: "${BSDKIT_VERSION:=13.2}"
: "${BSDKIT_JAIL_NETWORK:=172.16.1.0/24}"
: "${ZFS_SWAP_SIZE:=4G}"

export IGNORE_OSVERSION=yes

cd /root

rm -f /root/.wget-hsts

# shellcheck disable=SC2016
chpass -p '$1$Kk8uqtid$UZr4tpkPw6388O6xDSFLt1' root

mv -v /boot/loader.conf.local /boot/.loader.conf

sed -i -e "/vfs\.root\.mountfrom/d;" /boot/.loader.conf
sed -i -e "/vfs\.zfs\.vdev\.cache\.size/d;" /boot/.loader.conf
sed -i -e "/vfs\.zfs\.arc_max/d;" /boot/.loader.conf
sed -i -e "/loader_logo/d;" /boot/.loader.conf

cat -s /boot/.loader.conf > /boot/loader.conf
rm -f -v /boot/.loader.conf

if kenv zfs_be_root > /dev/null 2>&1; then
    _zfs_pool=$(kenv zfs_be_root | cut -d'/' -f1)

    zfs create \
        -o canmount=off \
        "${_zfs_pool}"/usr/local

    zfs create \
        -o checksum=off \
        -o compression=off \
        -o dedup=off \
        -o sync=disabled \
        -o primarycache=none \
        -o org.freebsd:swap=on \
        -V "${ZFS_SWAP_SIZE}" \
        "${_zfs_pool}"/swap
fi

zfs destroy -r "${_zfs_pool}"@base_installation || :
zfs destroy -r "${_zfs_pool}"@digitalocean_installation || :

pw userdel freebsd -r || :

mkdir -p /usr/local/etc/pkg/repos

while ! pkg install -y ports-mgmt/pkg; do :; done

# shellcheck disable=SC2016
echo 'bsdkit: { url: "https://hub.olgeni.com/FreeBSD/packages-${ABI}-default-nox11" }' > /usr/local/etc/pkg/repos/bsdkit.conf

for i in $(pkg query -g %n 'py37-*'); do pkg set -yn ${i}:py38-${i#py37-}; done

pkg update -f

while ! pkg upgrade -y; do :; done

while ! pkg install -y devel/git sysutils/pv sysutils/ansible shells/zsh; do :; done

git clone https://gitlab.com/olgeni/bsdkit.git
cd bsdkit
git checkout ${BSDKIT_BRANCH}
./bsdkit ansible-local-playbook

if route get default | grep "interface:" > /dev/null 2>&1; then
    _iface=$(route get default | awk '/interface:/ { print $2 }')
    echo "nat on ${_iface} from ${BSDKIT_JAIL_NETWORK} to any -> egress" > /etc/pf.conf
    echo 'anchor "f2b/*"' >> /etc/pf.conf
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
sysrc -x route_net0 || :

rm -f /usr/local/etc/rc.d/digitalocean
rm -f /usr/local/etc/rc.d/digitaloceanpre
rm -f /usr/local/etc/sudoers.d/90-cloud-init-users
rm -f /root/.cloud-locale-test.skip

pkg delete -y net/cloud-init python2 python27 || :
pkg delete -y -g py27\* || :
pkg autoremove -y || :
pkg clean -y -a || :

rm -r -f /usr/tests
rm -r -f /usr/lib/debug

./bsdkit-upgrade -v${BSDKIT_VERSION} -F
./bsdkit-upgrade -v${BSDKIT_VERSION} -n bsdkit
rm -r -f /usr/freebsd-dist/
cd /root

bectl mount bsdkit /mnt

cat << "EOF" > /mnt/etc/rc.d/digitalocean_boot
#!/bin/sh

# PROVIDE: digitalocean_boot
# REQUIRE: DAEMON
# KEYWORD: firstboot

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/root/bin

gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 vtbd0
zfs upgrade -a
zpool upgrade -a
bectl destroy -Fo default || :

pkg upgrade -F -y
pkg upgrade -y

touch /firstboot-reboot
rm -f /etc/rc.d/digitalocean_boot
EOF

chmod 555 /mnt/etc/rc.d/digitalocean_boot

touch /mnt/firstboot

bectl umount bsdkit

for _file in /var/log/*; do
    : > ${_file}
done

newsyslog -C -v

shutdown -r now

exec > /dev/tty 2>&1
