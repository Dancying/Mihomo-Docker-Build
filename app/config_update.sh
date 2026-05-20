#!/bin/bash

set -e

[ -z "$SUB_URL" ] && { return 0 2>/dev/null || exit 0; }

CONFIG_DIR="/config"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
HISTORY_DIR="$CONFIG_DIR/history"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_FILE="$CONFIG_DIR/temp_download.yaml"

update_config_kv() {
    local key="$1"
    local value="$2"
    
    [ -z "$value" ] && return 0
    
    grep -q "^${key}:" "$CONFIG_FILE" && sed -i "s/^${key}:.*/${key}: $value/" "$CONFIG_FILE" && return 0
    sed -i "1i ${key}: $value" "$CONFIG_FILE"
}

USER_AGENTS=("Clash" "Mihomo")
VALID_DOWNLOAD=false

for ua in "${USER_AGENTS[@]}"; do
    curl -s -L -H "User-Agent: $ua" "$SUB_URL" -o "$TEMP_FILE"
    
    if [ "$(wc -l < "$TEMP_FILE" || echo 0)" -le 10 ]; then
        mkdir -p "$HISTORY_DIR"
        mv "$TEMP_FILE" "$HISTORY_DIR/config_${TIMESTAMP}_failed_${ua,,}.yaml"
        continue
    fi
    
    mkdir -p "$HISTORY_DIR"
    [ -f "$CONFIG_FILE" ] && mv "$CONFIG_FILE" "$HISTORY_DIR/config_${TIMESTAMP}.yaml"
    mv "$TEMP_FILE" "$CONFIG_FILE"
    VALID_DOWNLOAD=true
    break
done

[ "$VALID_DOWNLOAD" = false ] && { return 0 2>/dev/null || exit 0; }
[ ! -f "$CONFIG_FILE" ] && { return 0 2>/dev/null || exit 0; }

update_config_kv "ipv6" "$IPV6"
update_config_kv "mode" "$MIHOMO_MODE"
update_config_kv "allow-lan" "$ALLOW_LAN"
update_config_kv "mixed-port" "$MIXED_PORT"

[ "$1" = "cron" ] && killall -9 mihomo 2>/dev/null || true
