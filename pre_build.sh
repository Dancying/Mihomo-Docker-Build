#!/bin/bash

set -e

MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/download/v1.19.31/mihomo-linux-amd64-v2-v1.19.31.gz"
METADB_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb"
GEOSITE_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
WEBUI_URL="https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

APP_DIR="./app"
RES_DIR="$APP_DIR/res"

mkdir -p "$RES_DIR"

echo "====> [1/4] Downloading rule databases..."
curl -L -o "$RES_DIR/geoip.metadb" "$METADB_URL"
curl -L -o "$RES_DIR/geosite.dat" "$GEOSITE_URL"

echo "====> [2/4] Downloading and deploying Mihomo core..."
curl -L -o "$APP_DIR/mihomo.gz" "$MIHOMO_URL"
gzip -d -c "$APP_DIR/mihomo.gz" > "$APP_DIR/mihomo"
rm -f "$APP_DIR/mihomo.gz"

echo "====> [3/4] Downloading and deploying Web UI..."
curl -L -o "$RES_DIR/ui.zip" "$WEBUI_URL"
unzip -q "$RES_DIR/ui.zip" -d "$RES_DIR"
EXTRACTED_UI_DIR=$(find "$RES_DIR" -maxdepth 1 -mindepth 1 -type d | head -n 1)
mv "$EXTRACTED_UI_DIR" "$RES_DIR/WEBUI"
rm -f "$RES_DIR/ui.zip"

echo "====> [4/4] Pre-build process completed successfully."
