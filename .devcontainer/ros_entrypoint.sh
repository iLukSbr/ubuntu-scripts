#!/usr/bin/env bash
set -e

# Fix D-Bus and X11 issues
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
export XDG_RUNTIME_DIR=/tmp
mkdir -p /tmp/runtime-root
chmod 700 /tmp/runtime-root
export XAUTHORITY=/tmp/.docker.xauth
touch $XAUTHORITY

# Generate the X11 authentication file
if [ -n "$DISPLAY" ]; then
    xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTHORITY nmerge - || echo "Warning: Failed to generate xauth entries"
else
    echo "Warning: DISPLAY environment variable is not set. X11 forwarding may not work."
fi

# Execute the provided command
if [ "$#" -eq 0 ]; then
    exec bash
else
    exec "$@"
fi
