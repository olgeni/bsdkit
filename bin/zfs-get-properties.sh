#!/bin/sh

set -e -u

zfs get -r -s local -H all "$1" | awk '{ print "zfs set " $2 "=\"" $3 "\" " $1; }'
