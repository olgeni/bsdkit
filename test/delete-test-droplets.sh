#!/bin/sh

set -eu

SCRIPT_DIR=$(cd "$(dirname "${0}")" && pwd)

# State file written by create-test-droplets.sh
IDS_FILE="${SCRIPT_DIR}/droplet-ids.txt"

if [ ! -f "${IDS_FILE}" ]; then
    echo "Error: ${IDS_FILE} not found!"
    echo "No droplets to delete."
    exit 1
fi

echo "Reading droplet IDs from ${IDS_FILE}..."
cat "${IDS_FILE}"

echo ""
echo "Deleting droplets..."

# The || [ -n ... ] clause processes a final line lacking a trailing newline
FAILED_IDS=""
while read -r droplet_id || [ -n "${droplet_id}" ]; do
    if [ -z "${droplet_id}" ]; then
        continue
    fi
    echo "Deleting droplet ${droplet_id}..."
    if ! doctl compute droplet delete "${droplet_id}" --force; then
        echo "Warning: failed to delete droplet ${droplet_id}"
        FAILED_IDS="${FAILED_IDS} ${droplet_id}"
    fi
done < "${IDS_FILE}"

echo ""

if [ -n "${FAILED_IDS}" ]; then
    # shellcheck disable=SC2086 # intentional splitting: one ID per line
    printf '%s\n' ${FAILED_IDS} > "${IDS_FILE}"
    echo "Some droplets could not be deleted:${FAILED_IDS}"
    echo "Their IDs were kept in ${IDS_FILE}."
    echo "Fix the problem (or remove stale IDs from the file) and re-run."
    exit 1
fi

echo "All test droplets deleted!"
echo "Removing ${IDS_FILE}..."
rm "${IDS_FILE}"

echo "Done!"
