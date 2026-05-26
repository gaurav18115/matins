#!/usr/bin/env bash
# .continuity/observe/sentry.sh — Sentry error rate (last 24h)
#
# Required env:
#   SENTRY_AUTH_TOKEN     — Sentry API token (Project: Read)
#   SENTRY_ORG_SLUG       — e.g. "mindweave"
#   SENTRY_PROJECT_SLUG   — e.g. "niptao-web"
#
# Optional env:
#   SENTRY_API_BASE       — default https://sentry.io/api/0
#
# Output: appends one JSONL row to .continuity/observations.jsonl
#   {"ts":"...","signal":"sentry_error_rate_24h","value":<pct>,"band":"...","raw":{...}}

set -euo pipefail

: "${SENTRY_AUTH_TOKEN:?SENTRY_AUTH_TOKEN is required}"
: "${SENTRY_ORG_SLUG:?SENTRY_ORG_SLUG is required}"
: "${SENTRY_PROJECT_SLUG:?SENTRY_PROJECT_SLUG is required}"
SENTRY_API_BASE="${SENTRY_API_BASE:-https://sentry.io/api/0}"

OBS_FILE="${OBS_FILE:-.continuity/observations.jsonl}"
mkdir -p "$(dirname "$OBS_FILE")"

now_iso="$(python3 -c 'import datetime; print(datetime.datetime.utcnow().isoformat()+"Z")')"

# Fetch error event counts for last 24h. Sentry's stats endpoint returns
# event totals per interval. We sum and divide by session count for a rate.
stats_resp=$(curl -sS -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  "$SENTRY_API_BASE/projects/$SENTRY_ORG_SLUG/$SENTRY_PROJECT_SLUG/stats/?stat=received&since=$(($(date +%s) - 86400))&resolution=1h")

events_24h=$(echo "$stats_resp" | jq '[.[] | .[1]] | add // 0')

# Session count for error_rate denominator (requires session tracking enabled).
# If unavailable, fall back to events-per-hour as the signal.
sessions_24h=$(curl -sS -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  "$SENTRY_API_BASE/organizations/$SENTRY_ORG_SLUG/sessions/?project=$SENTRY_PROJECT_SLUG&field=sum(session)&statsPeriod=24h&interval=24h" \
  | jq '[.groups[0].totals."sum(session)"] // [0] | first' 2>/dev/null || echo 0)

if [ "$sessions_24h" -gt 0 ] 2>/dev/null; then
  rate=$(python3 -c "print(round(${events_24h} / ${sessions_24h} * 100, 3))")
  signal="sentry_error_rate_24h"
  value="$rate"
else
  # No session tracking — report events-per-hour as the signal.
  rate=$(python3 -c "print(round(${events_24h} / 24, 2))")
  signal="sentry_events_per_hour_24h"
  value="$rate"
fi

echo "{\"ts\":\"$now_iso\",\"signal\":\"$signal\",\"value\":$value,\"raw\":{\"events_24h\":$events_24h,\"sessions_24h\":$sessions_24h}}" \
  >> "$OBS_FILE"

echo "[sentry] $signal=$value (events=$events_24h sessions=$sessions_24h)"
