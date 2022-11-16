#!/bin/sh

USER_ID=${LOCAL_UID:-9001}
GROUP_ID=${LOCAL_GID:-9001}

HOME="/opt/pleroma"
DATA="/var/lib/pleroma"

echo "Starting with UID : $USER_ID, GID: $GROUP_ID"
groupadd -g "$GROUP_ID" pleroma
useradd -u "$USER_ID" -d ${HOME} -o -m -g pleroma pleroma

export HOME=/opt/pleroma

chown -R pleroma:pleroma "$HOME"
chown -R pleroma:pleroma "$DATA"

exec su-exec pleroma "$HOME/docker-entrypoint.sh"