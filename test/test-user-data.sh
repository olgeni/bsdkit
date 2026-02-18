#!/bin/sh

set -e -u -o pipefail

mkdir -p /root/.ssh

echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNPW7mEm47dypwLebwlbfshn3lyslAS8p6zktyIieX2' >> /root/.ssh/authorized_keys

mkdir -p /usr/local/etc/pkg/repos/

cat << EOF > /usr/local/etc/pkg/repos/FreeBSD.conf
FreeBSD: {
    enabled: no
}
FreeBSD-ports: {
    enabled: no
}
FreeBSD-ports-kmods: {
    enabled: no
}
FreeBSD-base: {
    enabled: no
}
EOF

cat << EOF > /usr/local/etc/pkg/repos/bsdkit.conf
bsdkit: {
    url: "https://hub.olgeni.com/FreeBSD/packages-\${ABI}-default-nox11"
}
EOF

pkg update --force

pkg install --yes zsh git

/usr/local/bin/git clone https://gitlab.com/olgeni/bsdkit.git/ /usr/local/bsdkit

ln -s /usr/local/bsdkit/bsdkit /usr/local/sbin/bsdkit

/usr/local/sbin/bsdkit configure
