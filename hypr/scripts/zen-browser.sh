#!/usr/bin/env bash

# Define the target application executable name
APP_NAME="zen-browser"
CLIENT_NAME="zen"

if [[ $(pgrep -f -x "$APP_NAME") ]]; then
  echo "$APP_NAME is running"
  exit 1
fi

# Requires uwsm to be installed
hyprctl dispatch exec "uwsm app -- $APP_NAME"

# Use pgrep -f to match against the full command line, avoiding the 15-char limit
if [[ $(pgrep -f -x "$APP_NAME") ]]; then
  echo "$APP_NAME is running"
  exit 1
fi

for _ in {1..100}; do
  addr=$(hyprctl clients -j | jq -r --arg app_class "$CLIENT_NAME" '.[] | select(.class == $app_class) | .address')

  if [[ -n "$addr" && "$addr" != "null" ]]; then
    break
  fi

  sleep 0.1
done

if [[ -n "$addr" && "$addr" != "null" ]]; then
  hyprctl dispatch movetoworkspace "special:magic,address:$addr"
  sleep 0.5
  hyprctl dispatch togglespecialworkspace magic
else
  echo "Window for $APP_NAME not found"
  exit 1
fi