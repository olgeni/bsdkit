# bsdkit

## FreeBSD OCI images

    export OCIBASE=https://download.freebsd.org/releases/OCI-IMAGES/14.3-RELEASE/amd64/Latest

    podman load -i=$OCIBASE/FreeBSD-14.3-RELEASE-amd64-container-image-minimal.txz
    podman load -i=$OCIBASE/FreeBSD-14.3-RELEASE-amd64-container-image-dynamic.txz
    podman load -i=$OCIBASE/FreeBSD-14.3-RELEASE-amd64-container-image-static.txz
