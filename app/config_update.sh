#!/bin/bash

set -e

CONFIG_DIR="/config"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
HISTORY_DIR="$CONFIG_DIR/history"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_CONFIG_FILE="/tmp/mihomo_download_config.yaml"

if [[ -n "$SUB_URL" && "$SUB_URL" == http?(s)://* ]]; then
    DOWNLOAD_OK=false

    if [ "$USE_PROXYSCOTCH" = "true" ]; then
        echo "====> Downloading via Proxyscotch..."
        PAYLOAD="{\"url\":\"$SUB_URL\",\"method\":\"GET\",\"wantsBinary\":true,\"headers\":{\"User-Agent\":\"clash meta mihomo\"}}"

        if RESPONSE=$(curl -sS -L --noproxy "*" --connect-timeout 30 -m 30 \
            -X POST "https://proxy.hoppscotch.io/" \
            -H "Content-Type: application/json" \
            -H "Origin: https://hoppscotch.io" \
            -d "$PAYLOAD" 2>&1); then
            B64_DATA=$(echo "$RESPONSE" | sed -n 's/.*"data":"\([^"]*\)".*/\1/p')

            MOD=$((${#B64_DATA} % 4))
            [ "$MOD" -eq 2 ] && B64_DATA="${B64_DATA}=="
            [ "$MOD" -eq 3 ] && B64_DATA="${B64_DATA}="
            echo "$B64_DATA" | base64 -d > "$TEMP_CONFIG_FILE" 2>/dev/null
            DOWNLOAD_OK=true
        else
            echo "====> Config download failed: $RESPONSE"
        fi
    else
        echo "====> Downloading via direct curl..."
        if ! CURL_ERR=$(curl -sS -L --noproxy "*" --connect-timeout 30 -m 30 \
            -H "User-Agent: clash meta mihomo" \
            -o "$TEMP_CONFIG_FILE" "$SUB_URL" 2>&1); then
            echo "====> Config download failed: $CURL_ERR"
        else
            DOWNLOAD_OK=true
        fi
    fi

    if [ "$DOWNLOAD_OK" = "true" ]; then
        mkdir -p "$HISTORY_DIR"

        if /app/mihomo -t -d "$CONFIG_DIR" -f "$TEMP_CONFIG_FILE" >/dev/null 2>&1; then
            [ -f "$CONFIG_FILE" ] && mv "$CONFIG_FILE" "$HISTORY_DIR/config_${TIMESTAMP}.yaml"
            mv "$TEMP_CONFIG_FILE" "$CONFIG_FILE"
        else
            echo "====> Config validation failed."
            mv "$TEMP_CONFIG_FILE" "$HISTORY_DIR/config_${TIMESTAMP}_failed.yaml"
        fi

        find "$HISTORY_DIR" -type f -mtime +7 -name "config_*.yaml" -exec rm -f {} +
    fi
fi

YQ_EXPR=""
DEL_KEYS=""
OBJ_KEYS=""

register_key() {
    local key="$1"
    DEL_KEYS="${DEL_KEYS}.${key}, "
    OBJ_KEYS="${OBJ_KEYS}\"${key}\": .${key}, "
}

[ -n "$MIXED_PORT" ] && YQ_EXPR="${YQ_EXPR} .mixed-port = $MIXED_PORT |" && register_key "mixed-port"
[ -n "$ALLOW_LAN" ] && YQ_EXPR="${YQ_EXPR} .allow-lan = $ALLOW_LAN |" && register_key "allow-lan"
[ -n "$IPV6" ] && YQ_EXPR="${YQ_EXPR} .ipv6 = $IPV6 |" && register_key "ipv6"
[ -n "$MIHOMO_MODE" ] && YQ_EXPR="${YQ_EXPR} .mode = \"$MIHOMO_MODE\" |" && register_key "mode"
[ -n "$BIND_ADDRESS" ] && YQ_EXPR="${YQ_EXPR} .bind-address = \"$BIND_ADDRESS\" |" && register_key "bind-address"
[ -n "$AUTHENTICATION" ] && export AUTHENTICATION && YQ_EXPR="${YQ_EXPR} .authentication = (env(AUTHENTICATION) | split(\",\") | .[] style=\"double\") |" && register_key "authentication"
[ -n "$SKIP_AUTH_PREFIXES" ] && export SKIP_AUTH_PREFIXES && YQ_EXPR="${YQ_EXPR} .skip-auth-prefixes = (env(SKIP_AUTH_PREFIXES) | split(\",\")) |" && register_key "skip-auth-prefixes"

if [ -n "$EXTRA_CONFIG_REPLACE" ] && [ -f "$EXTRA_CONFIG_REPLACE" ]; then
    if yq eval '.' "$EXTRA_CONFIG_REPLACE" >/dev/null 2>&1; then
        yq eval -i '. * load("'$EXTRA_CONFIG_REPLACE'")' "$CONFIG_FILE"
        OVERRIDE_KEYS=$(yq eval 'keys | .[]' "$EXTRA_CONFIG_REPLACE" 2>/dev/null || true)
        for key in $OVERRIDE_KEYS; do
            register_key "$key"
        done
        echo "====> Extra config replace applied."
    else
        echo "====> Extra config file invalid."
    fi
elif [ -n "$EXTRA_CONFIG_REPLACE" ]; then
    echo "====> Extra config file missing."
fi

if [ -n "$YQ_EXPR" ] || [ -n "$DEL_KEYS" ]; then
    [ -n "$YQ_EXPR" ] && yq eval -i "${YQ_EXPR% |}" "$CONFIG_FILE"
    yq eval -i ". as \$rest | ({ ${OBJ_KEYS%, } } | with_entries(select(.value != null))) + (\$rest | del(${DEL_KEYS%, }))" "$CONFIG_FILE"
fi
