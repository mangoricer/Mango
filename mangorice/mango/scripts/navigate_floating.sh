#!/bin/bash

DIR=$1
SCREEN_W=1920   #  поставь своё разрешение
SCREEN_H=1080

CLIENTS=$(mmsg get all-clients 2>/dev/null)
[ -z "$CLIENTS" ] && exit 0

FOCUSED=$(echo "$CLIENTS" | jq -r '.clients[] | select(.is_focused == true) | .id')
[ -z "$FOCUSED" ] && exit 0

FX=$(echo "$CLIENTS" | jq -r ".clients[] | select(.id == $FOCUSED) | .x")
FY=$(echo "$CLIENTS" | jq -r ".clients[] | select(.id == $FOCUSED) | .y")

TARGET=$(echo "$CLIENTS" | jq -r --argjson fx "$FX" --argjson fy "$FY" --arg dir "$DIR" '
  .clients
  | map(select(.is_floating == true and .id != '"$FOCUSED"'))
  | map(. + {cx: (.x + .width/2), cy: (.y + .height/2)})
  | if $dir == "left" then
      map(select(.cx < $fx)) | sort_by(-.cx) | .[0]
    elif $dir == "right" then
      map(select(.cx > $fx)) | sort_by(.cx) | .[0]
    elif $dir == "up" then
      map(select(.cy < $fy)) | sort_by(-.cy) | .[0]
    elif $dir == "down" then
      map(select(.cy > $fy)) | sort_by(.cy) | .[0]
    else empty end
  | .id // empty
')

[ -z "$TARGET" ] && exit 0

TX=$(echo "$CLIENTS" | jq -r ".clients[] | select(.id == $TARGET) | .x")
TY=$(echo "$CLIENTS" | jq -r ".clients[] | select(.id == $TARGET) | .y")
TW=$(echo "$CLIENTS" | jq -r ".clients[] | select(.id == $TARGET) | .width")
TH=$(echo "$CLIENTS" | jq -r ".clients[] | select(.id == $TARGET) | .height")

DX=$(( SCREEN_W/2 - (TX + TW/2) ))
DY=$(( SCREEN_H/2 - (TY + TH/2) ))

IDS=$(echo "$CLIENTS" | jq -r '.clients[] | select(.is_floating == true) | .id')
for id in $IDS; do
    mmsg dispatch movewin,+$DX,+$DY client,$id 2>/dev/null
done

mmsg dispatch focusid client,$TARGET 2>/dev/null