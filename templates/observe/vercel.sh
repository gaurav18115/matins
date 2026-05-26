#!/usr/bin/env bash
# .continuity/observe/vercel.sh — Vercel runtime cost + function errors (last 24h)
#
# Required env:
#   VERCEL_TOKEN            — Vercel API token (scope: read project + read team)
#   VERCEL_PROJECT_ID       — e.g. "prj_abc123" (find via `vercel inspect`)
#
# Optional env:
#   VERCEL_TEAM_ID          — required if the project is in a team
#
# Output: two JSONL rows
#   - vercel_runtime_gbhrs_24h     (compute used in last 24h)
#   - vercel_function_errors_24h   (5xx count from runtime logs)
#
# Notes:
#   This uses Vercel's Usage API + Logs API. Both endpoints are stable but
#   field names occasionally drift — check https://vercel.com/docs/rest-api
#   if numbers look wrong.

set -euo pipefail

: "${VERCEL_TOKEN:?VERCEL_TOKEN is required}"
: "${VERCEL_PROJECT_ID:?VERCEL_PROJECT_ID is required}"

team_q=""
if [ -n "${VERCEL_TEAM_ID:-}" ]; then
  team_q="&teamId=$VERCEL_TEAM_ID"
fi

OBS_FILE="${OBS_FILE:-.continuity/observations.jsonl}"
mkdir -p "$(dirname "$OBS_FILE")"

now_iso="$(python3 -c 'import datetime; print(datetime.datetime.utcnow().isoformat()+"Z")')"
from_ts=$(( $(date +%s) - 86400 ))000
to_ts=$(( $(date +%s) ))000

# 1. Runtime GB-Hrs in last 24h.
usage=$(curl -sS -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v1/usage?from=$from_ts&until=$to_ts&projectId=$VERCEL_PROJECT_ID$team_q")
gbhrs=$(echo "$usage" | jq '[.usage[]? | select(.name == "Functions: Compute") | .value] | add // 0')

# 2. Function errors (5xx) in last 24h via logs API.
logs=$(curl -sS -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v2/deployments/logs?projectId=$VERCEL_PROJECT_ID&from=$from_ts&until=$to_ts&statusCode=5XX&limit=1000$team_q")
errors=$(echo "$logs" | jq '[.logs[]?] | length // 0')

echo "{\"ts\":\"$now_iso\",\"signal\":\"vercel_runtime_gbhrs_24h\",\"value\":$gbhrs,\"raw\":{}}" >> "$OBS_FILE"
echo "{\"ts\":\"$now_iso\",\"signal\":\"vercel_function_errors_24h\",\"value\":$errors,\"raw\":{}}" >> "$OBS_FILE"

echo "[vercel] runtime_gbhrs_24h=$gbhrs function_errors_24h=$errors"
