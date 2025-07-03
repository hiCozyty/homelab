#!/usr/bin/env bash

TARGET_WS=9
SCRIPT_TO_RUN="$1"
KITTY_CLASS="kitty-wrapper"

# Check if we're already on the correct workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq '.id')
if [[ "$CURRENT_WS" -ne "$TARGET_WS" ]]; then
    hyprctl dispatch workspace "$TARGET_WS"
    sleep 0.1
fi

# Check if a kitty window with the correct class exists on workspace 9
KITTY_ON_WS=$(hyprctl clients -j | jq -e \
    --argjson ws "$TARGET_WS" \
    --arg class "$KITTY_CLASS" \
    '.[] | select(.workspace.id == $ws and .class == $class)' > /dev/null)

if [[ $? -ne 0 ]]; then
    # No such kitty window; spawn one and run the script
    hyprctl dispatch exec "kitty --class $KITTY_CLASS bash -ic '$SCRIPT_TO_RUN'"
else
    # close and re-launch:
    hyprctl dispatch killactive
    sleep 0.2
    hyprctl dispatch exec "kitty --class $KITTY_CLASS bash -ic '$SCRIPT_TO_RUN'"
fi
