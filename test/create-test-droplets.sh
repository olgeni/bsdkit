#!/bin/sh

set -eu

SCRIPT_DIR=$(cd "$(dirname "${0}")" && pwd)

# State file recording created droplet IDs, consumed by delete-test-droplets.sh
IDS_FILE="${SCRIPT_DIR}/droplet-ids.txt"

# Default FreeBSD version
VERSION="14.3"

# Parse command line options
USERDATA_FILE=""
FILESYSTEM="both"
while getopts "f:u:v:" opt; do
    case ${opt} in
        f)
            FILESYSTEM="${OPTARG}"
            ;;
        u)
            USERDATA_FILE="${OPTARG}"
            ;;
        v)
            VERSION="${OPTARG}"
            ;;
        *)
            echo "Usage: ${0} [-f filesystem] [-u user-data-file] [-v version]"
            echo "  -f filesystem   Filesystem type: ufs, zfs, or both (default: both)"
            echo "  -u file         Path to user data script file"
            echo "  -v version      FreeBSD version to test (default: 14.3)"
            exit 1
            ;;
    esac
done

# Validate filesystem option and expand it to the list of filesystems to test
case "${FILESYSTEM}" in
    ufs|zfs)
        FILESYSTEMS="${FILESYSTEM}"
        ;;
    both)
        FILESYSTEMS="ufs zfs"
        ;;
    *)
        echo "Error: Invalid filesystem option '${FILESYSTEM}'. Must be: ufs, zfs, or both"
        exit 1
        ;;
esac

# Validate user data file if specified
if [ -n "${USERDATA_FILE}" ]; then
    if [ ! -f "${USERDATA_FILE}" ]; then
        echo "Error: User data file not found: ${USERDATA_FILE}"
        exit 1
    fi
    echo "User data will be included from: ${USERDATA_FILE}"
    echo ""
else
    echo "No user data will be included."
    echo ""
fi

# Refuse to clobber the record of a previous run: its droplets may still be
# running, and overwriting the file would orphan them.
if [ -f "${IDS_FILE}" ]; then
    echo "Error: ${IDS_FILE} already exists."
    echo "Droplets from a previous run may still be running."
    echo "Run delete-test-droplets.sh first (or remove the file if it is stale)."
    exit 1
fi

# SSH key for olgeni@olgeni.com (override with BSDKIT_TEST_SSH_KEYS)
SSH_KEYS="${BSDKIT_TEST_SSH_KEYS:-19:66:b5:77:38:f9:a4:20:2f:1e:38:98:62:9b:fd:79}"

# Region
REGION="${BSDKIT_TEST_REGION:-fra1}"

# Droplet size (4GB for ZFS boot)
SIZE="${BSDKIT_TEST_SIZE:-s-2vcpu-4gb}"

# Version with regex metacharacters escaped, so 14.3 does not match 14.30
VERSION_RE=$(printf '%s' "${VERSION}" | sed 's/\./\\./g')

# Print the image ID matching the given filesystem, or fail with a report.
# Uses IMAGE_LIST fetched once below.
find_image() {
    fs="${1}"
    pattern="FreeBSD-${VERSION_RE}-.*-amd64-BASIC-CLOUDINIT.*-${fs}[[:space:]]*$"

    matches=$(printf '%s\n' "${IMAGE_LIST}" | grep "${pattern}" || true)

    if [ -z "${matches}" ]; then
        echo "Error: FreeBSD-${VERSION}*-amd64-BASIC-CLOUDINIT*-${fs} image not found!" >&2
        return 1
    fi

    count=$(printf '%s\n' "${matches}" | wc -l | tr -d ' ')
    if [ "${count}" -gt 1 ]; then
        echo "Error: Multiple FreeBSD-${VERSION}*-amd64-BASIC-CLOUDINIT*-${fs} images found!" >&2
        echo "Please ensure only one matching image exists." >&2
        echo "Found images:" >&2
        printf '%s\n' "${matches}" >&2
        return 1
    fi

    printf '%s\n' "${matches}" | awk '{print $1}'
}

# Create a droplet and print its ID
create_droplet() {
    fs="${1}"
    image="${2}"

    set -- \
        --image "${image}" \
        --size "${SIZE}" \
        --region "${REGION}" \
        --ssh-keys "${SSH_KEYS}" \
        --format ID \
        --no-header

    if [ -n "${USERDATA_FILE}" ]; then
        set -- "$@" --user-data-file "${USERDATA_FILE}"
    fi

    doctl compute droplet create "freebsd-${VERSION}-amd64-${fs}-test" "$@"
}

# Find FreeBSD images (single API call), failing before any droplet is created
echo "Finding FreeBSD ${VERSION} images..."
IMAGE_LIST=$(doctl compute image list --format ID,Name --no-header)

for fs in ${FILESYSTEMS}; do
    image=$(find_image "${fs}")
    echo "Found ${fs} image: ${image}"
    eval "IMAGE_${fs}=\"\${image}\""
done

echo ""

# Create droplets, recording each ID immediately so a later failure cannot
# orphan an already-created droplet.
DROPLET_IDS=""
for fs in ${FILESYSTEMS}; do
    echo "Creating FreeBSD ${VERSION} ${fs} droplet..."
    eval "image=\"\${IMAGE_${fs}}\""
    droplet_id=$(create_droplet "${fs}" "${image}")
    echo "${droplet_id}" >> "${IDS_FILE}"
    echo "${fs} droplet ID: ${droplet_id}"
    eval "DROPLET_${fs}=\"\${droplet_id}\""
    DROPLET_IDS="${DROPLET_IDS} ${droplet_id}"
done

echo ""
echo "Droplet IDs saved to ${IDS_FILE}"
echo ""
echo "Waiting for droplets to get IP addresses..."

# Wait for droplets to get IP addresses
attempt=1
while :; do
    pending=""
    for fs in ${FILESYSTEMS}; do
        eval "ip=\"\${IP_${fs}:-}\""
        if [ -z "${ip}" ]; then
            eval "droplet_id=\"\${DROPLET_${fs}}\""
            ip=$(doctl compute droplet get "${droplet_id}" --format PublicIPv4 --no-header 2>/dev/null || true)
            eval "IP_${fs}=\"\${ip}\""
        fi
        if [ -z "${ip}" ]; then
            pending="${pending} ${fs}"
        fi
    done

    if [ -z "${pending}" ]; then
        break
    fi

    if [ "${attempt}" -ge 15 ]; then
        echo "Warning: timed out waiting for IP addresses on:${pending}"
        break
    fi

    echo "  Attempt ${attempt}/15: Waiting for IP addresses..."
    sleep 3
    attempt=$((attempt + 1))
done

echo ""
echo "Droplets created:"
for fs in ${FILESYSTEMS}; do
    eval "droplet_id=\"\${DROPLET_${fs}}\""
    eval "ip=\"\${IP_${fs}:-}\""
    echo "  freebsd-${VERSION}-amd64-${fs}-test (${droplet_id}): ${ip:-<pending>}"
done
