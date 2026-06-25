#!/bin/bash

set -e

source /app/dir_init.sh

source /app/config_update.sh

bash /app/cron_setup.sh &

[ -z "$WEBUI_LISTEN_ADDR" ] && WEBUI_LISTEN_ADDR="0.0.0.0:9090"

if [ -z "$WEBUI_SECRET" ]; then
    WEBUI_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 8)
    echo "***************************************************"
    echo " Generated random Web UI password: $WEBUI_SECRET"
    echo "***************************************************"
fi

_term() {
    killall -9 mihomo 2>/dev/null || true
    exit 0
}
trap _term SIGTERM SIGINT SIGHUP

echo "====> Starting Mihomo core engine loop..."
RETRY_COUNT=0
MAX_RETRIES=5

while [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; do
    START_TIME=$(date +%s)
    
    /app/mihomo -d /config -f /config/config.yaml -ext-ctl "$WEBUI_LISTEN_ADDR" -ext-ui /config/WEBUI -secret "${WEBUI_SECRET}" &
    MIHOMO_PID=$!
    
    wait "$MIHOMO_PID" || true
    killall -9 mihomo 2>/dev/null || true
    
    END_TIME=$(date +%s)
    RUNTIME=$((END_TIME - START_TIME))
    
    if [ "$RUNTIME" -lt 5 ]; then
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "====> WARNING: Mihomo core crashed too fast ($RUNTIME seconds). Retry $RETRY_COUNT/$MAX_RETRIES"
    else
        RETRY_COUNT=0
    fi
    
    [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ] && sleep 2
done

echo "====> ERROR: Mihomo core failed to start after $MAX_RETRIES attempts. Exiting."
exit 1
