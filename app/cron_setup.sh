#!/bin/bash

set -e

[ -z "$SUB_URL" ] || [ -z "$UPDATE_INTERVAL" ] || [ "$UPDATE_INTERVAL" -le 0 ] && { return 0 2>/dev/null || exit 0; }

while true; do
    sleep "${UPDATE_INTERVAL}h"
    bash /app/config_update.sh cron
done
