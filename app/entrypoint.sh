#!/bin/bash

set -e

source /app/dir_init.sh

source /app/cron_setup.sh

source /app/config_update.sh

[ -z "$WEBUI_LISTEN_ADDR" ] && WEBUI_LISTEN_ADDR="0.0.0.0:9090"

if [ -z "$WEBUI_SECRET" ]; then
    WEBUI_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 8)
    echo "***************************************************"
    echo " Generated random Web UI password: $WEBUI_SECRET"
    echo "***************************************************"
fi

trap "killall -9 mihomo 2>/dev/null || true; exit 0" SIGTERM
trap "killall -9 mihomo 2>/dev/null || true" SIGHUP

echo "====> Starting Mihomo core engine loop..."
while true; do
    /app/mihomo -d /config -f /config/config.yaml -ext-ctl "$WEBUI_LISTEN_ADDR" -ext-ui /config/WEBUI -secret "${WEBUI_SECRET}"
    killall -9 mihomo 2>/dev/null || true
    sleep 2
done
