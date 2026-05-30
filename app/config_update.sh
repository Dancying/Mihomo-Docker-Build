#!/bin/bash

set -e

CONFIG_DIR="/config"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
HISTORY_DIR="$CONFIG_DIR/history"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_CONFIG_FILE="/tmp/mihomo_download_config.yaml"
TEMP_UA_CACHE_FILE="/tmp/mihomo_success_ua.txt"

update_config_kv() {
    local key="$1"
    local value="$2"
    
    [ -z "$value" ] && return 0
    
    grep -q "^${key}:" "$CONFIG_FILE" && sed -i "s/^${key}:.*/${key}: $value/" "$CONFIG_FILE" && return 0
    sed -i "1i ${key}: $value" "$CONFIG_FILE"
}

VALID_DOWNLOAD=false

if [ -n "$SUB_URL" ]; then
    USER_AGENTS=("clash" "mihomo")
    
    if [ -f "$TEMP_UA_CACHE_FILE" ]; then
        LAST_UA=$(cat "$TEMP_UA_CACHE_FILE")
        USER_AGENTS=("$LAST_UA" $(echo "${USER_AGENTS[@]}" | sed "s/\b$LAST_UA\b//g"))
    fi

    for ua in "${USER_AGENTS[@]}"; do
        curl -s -L -H "User-Agent: $ua" "$SUB_URL" -o "$TEMP_CONFIG_FILE"
        
        if [ "$(wc -l < "$TEMP_CONFIG_FILE" || echo 0)" -le 10 ]; then
            mkdir -p "$HISTORY_DIR"
            mv "$TEMP_CONFIG_FILE" "$HISTORY_DIR/config_${TIMESTAMP}_failed_${ua,,}.yaml"
            continue
        fi
        
        mkdir -p "$HISTORY_DIR"
        [ -f "$CONFIG_FILE" ] && mv "$CONFIG_FILE" "$HISTORY_DIR/config_${TIMESTAMP}.yaml"
        mv "$TEMP_CONFIG_FILE" "$CONFIG_FILE"
        VALID_DOWNLOAD=true
        echo "$ua" > "$TEMP_UA_CACHE_FILE"
        break
    done
fi

if [ -f "$CONFIG_FILE" ]; then
    update_config_kv "ipv6" "$IPV6"
    update_config_kv "bind-address" "$BIND_ADDRESS"
    update_config_kv "mode" "$MIHOMO_MODE"
    update_config_kv "allow-lan" "$ALLOW_LAN"
    update_config_kv "mixed-port" "$MIXED_PORT"
fi

[ "$1" = "cron" ] && [ "$VALID_DOWNLOAD" = true ] && killall -9 mihomo 2>/dev/null || true
