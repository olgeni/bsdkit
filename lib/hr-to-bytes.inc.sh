# -*- mode: sh -*-

BSDKIT_HR_TO_BYTES_INCLUDED="yes"

hr-to-bytes() {
    local size="${1}"
    local -A units=( [B]=1 [K]=1024 [M]=$((1024*1024)) [G]=$((1024*1024*1024)) [T]=$((1024*1024*1024*1024)) [P]=$((1024*1024*1024*1024*1024)) [E]=$((1024*1024*1024*1024*1024*1024)) )
    local unit="${size//[0-9.]/}"
    local num="${size%$unit}"

    # Fallback to bytes if no unit is present
    unit=${unit:-B}
    # Ensure that the unit is a single uppercase letter
    unit=$(echo "$unit" | tr '[:lower:]' '[:upper:]' | cut -c 1)

    # If unit is not a recognized symbol, return an error
    if [[ -z "${units[$unit]}" ]]; then
        echo "Error: Invalid unit '$unit' in input '$size'"
        return 1
    fi

    # Perform the calculation, format the number as an integer, and print the result
    local bytes
    bytes=$(awk "BEGIN {printf \"%d\", $num * ${units[$unit]}}")
    echo $bytes
}
