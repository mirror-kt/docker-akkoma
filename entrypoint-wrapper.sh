#!/bin/sh

USER_ID=${LOCAL_UID:-9001}
GROUP_ID=${LOCAL_GID:-9001}

HOME="/opt/akkoma"
DATA="/var/lib/akkoma"

echo "Starting with UID : $USER_ID, GID: $GROUP_ID"
groupadd -g "$GROUP_ID" akkoma
useradd -u "$USER_ID" -d ${HOME} -o -m -g akkoma akkoma

export HOME=/opt/akkoma

chown -R akkoma:akkoma "$HOME"
chown -R akkoma:akkoma "$DATA"

exec su-exec akkoma "$HOME/docker-entrypoint.sh"