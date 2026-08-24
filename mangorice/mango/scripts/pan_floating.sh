#!/bin/bash

DX=${1:-0}
DY=${2:-0}

CLIENTS=$(mmsg get all-clients 2>/dev/null)
[ -z "$CLIENTS" ] && exit 0

IDS=$(echo "$CLIENTS" | jq -r '.clients[] | select(.is_floating == true) | .id')

for id in $IDS; do
    mmsg dispatch movewin,+$DX,+$DY client,$id 2>/dev/null
done