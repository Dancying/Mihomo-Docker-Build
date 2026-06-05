#!/bin/bash

set -e

MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/download/v1.19.26/mihomo-linux-amd64-v2-v1.19.26.gz"
METADB_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb"
GEOSITE_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
UI_URL="https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

TEMP_DIR="./temp"
APP_DIR="./app"

mkdir -p "$TEMP_DIR"

echo "====> Downloading dependencies..."
curl -L -o "$TEMP_DIR/mihomo.gz" "$MIHOMO_URL"
curl -L -o "$APP_DIR/geoip.metadb" "$METADB_URL"
curl -L -o "$APP_DIR/geosite.dat" "$GEOSITE_URL"
curl -L -o "$TEMP_DIR/ui.zip" "$UI_URL"

echo "====> Extracting core..."
gzip -d -c "$TEMP_DIR/mihomo.gz" > "$APP_DIR/mihomo"
chmod +x "$APP_DIR/mihomo"

echo "====> Deploying Web UI..."
unzip -q "$TEMP_DIR/ui.zip" -d "$TEMP_DIR"
EXTRACTED_UI_DIR=$(find "$TEMP_DIR" -maxdepth 1 -mindepth 1 -type d | head -n 1)
mv "$EXTRACTED_UI_DIR" "$APP_DIR/WEBUI"

echo "====> Cleaning workspace..."
rm -rf "$TEMP_DIR"

echo "====> Done: All dependencies ready."
