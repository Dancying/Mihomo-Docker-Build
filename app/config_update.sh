#!/bin/bash

set -e

CONFIG_DIR="/config"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
HISTORY_DIR="$CONFIG_DIR/history"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_CONFIG_FILE="/tmp/mihomo_download_config.yaml"
TEMP_UA_CACHE_FILE="/tmp/mihomo_success_ua.txt"

VALID_DOWNLOAD=false

if [ -n "$SUB_URL" ]; then
    USER_AGENTS=("clash meta mihomo" "clash" "meta" "mihomo")
    
    if [ -f "$TEMP_UA_CACHE_FILE" ]; then
        LAST_UA=$(cat "$TEMP_UA_CACHE_FILE")
        USER_AGENTS=("$LAST_UA" $(echo "${USER_AGENTS[@]}" | sed "s/\b$LAST_UA\b//g"))
    fi

    for ua in "${USER_AGENTS[@]}"; do
        curl -s -L --connect-timeout 30 -m 30 -H "User-Agent: $ua" "$SUB_URL" -o "$TEMP_CONFIG_FILE"
        
        if [ "$(wc -l < "$TEMP_CONFIG_FILE" || echo 0)" -le 10 ]; then
            mkdir -p "$HISTORY_DIR"
            SAFE_UA=${ua// /_}
            mv "$TEMP_CONFIG_FILE" "$HISTORY_DIR/config_${TIMESTAMP}_failed_${SAFE_UA,,}.yaml"
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
    YQ_EXPR=""
    [ -n "$MIXED_PORT" ] && YQ_EXPR="${YQ_EXPR} .mixed-port = $MIXED_PORT |"
    [ -n "$ALLOW_LAN" ] && YQ_EXPR="${YQ_EXPR} .allow-lan = $ALLOW_LAN |"
    [ -n "$MIHOMO_MODE" ] && YQ_EXPR="${YQ_EXPR} .mode = \"$MIHOMO_MODE\" |"
    [ -n "$BIND_ADDRESS" ] && YQ_EXPR="${YQ_EXPR} .bind-address = \"$BIND_ADDRESS\" |"
    [ -n "$IPV6" ] && YQ_EXPR="${YQ_EXPR} .ipv6 = $IPV6 |"
    [ -n "$AUTHENTICATION" ] && export AUTHENTICATION && YQ_EXPR="${YQ_EXPR} .authentication = (env(AUTHENTICATION) | split(\",\") | .[] style=\"double\") |"

    if [ -n "$YQ_EXPR" ]; then
        yq eval -i "${YQ_EXPR% |}" "$CONFIG_FILE"
        yq eval -i ". = ({ \
            \"mixed-port\": .mixed-port, \
            \"allow-lan\": .allow-lan, \
            \"ipv6\": .ipv6, \
            \"mode\": .mode, \
            \"bind-address\": .bind-address, \
            \"authentication\": .authentication \
        } + .) | del(.. | select(. == null))" "$CONFIG_FILE"
    fi
fi

[ "$1" = "cron" ] && [ "$VALID_DOWNLOAD" = true ] && killall -9 mihomo 2>/dev/null || true
