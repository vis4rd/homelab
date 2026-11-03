#!/bin/sh
set -eu

: "${JELLYFIN_API_KEY:?JELLYFIN_API_KEY is required}"

awk -v token="$JELLYFIN_API_KEY" '{gsub("__JELLYFIN_API_KEY__", token); print}' \
  /config/config.yml.template > /tmp/config.yml

exec /bin/json_exporter --config.file=/tmp/config.yml --log.level=warn
