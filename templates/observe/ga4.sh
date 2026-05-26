#!/usr/bin/env bash
# .continuity/observe/ga4.sh — GA4 signups (24h) + sessions
#
# Required env:
#   GA4_PROPERTY_ID         — numeric, e.g. "350123456"
#   GOOGLE_APPLICATION_CREDENTIALS — path to a service-account JSON with
#                                    "Viewer" role on the GA4 property
#
# Optional env:
#   GA4_SIGNUP_EVENT_NAME   — default "sign_up"
#
# Output: two JSONL rows to .continuity/observations.jsonl
#   - ga4_signups_24h
#   - ga4_sessions_24h
#
# Note: This calls the GA4 Data API via google-cloud-sdk's curl-with-token
# pattern. Alternatively, MCP-based agent runtimes can use the google-analytics
# MCP server (see https://github.com/gaurav18115/matins/blob/main/docs/ANALYTICS.md).

set -euo pipefail

: "${GA4_PROPERTY_ID:?GA4_PROPERTY_ID is required}"
: "${GOOGLE_APPLICATION_CREDENTIALS:?GOOGLE_APPLICATION_CREDENTIALS path required}"
SIGNUP_EVENT="${GA4_SIGNUP_EVENT_NAME:-sign_up}"

OBS_FILE="${OBS_FILE:-.continuity/observations.jsonl}"
mkdir -p "$(dirname "$OBS_FILE")"

now_iso="$(python3 -c 'import datetime; print(datetime.datetime.utcnow().isoformat()+"Z")')"

# Get an access token from the SA key.
access_token=$(python3 - <<'PY'
import json, time, base64, os, urllib.request, hashlib, hmac
from urllib.parse import urlencode
import jwt as _jwt  # PyJWT — pip install pyjwt cryptography
import google.auth  # google-auth — pip install google-auth requests
from google.oauth2 import service_account
import google.auth.transport.requests
creds = service_account.Credentials.from_service_account_file(
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"],
    scopes=["https://www.googleapis.com/auth/analytics.readonly"],
)
creds.refresh(google.auth.transport.requests.Request())
print(creds.token)
PY
)

# Query the GA4 Data API for signups and sessions in last 24h.
payload=$(cat <<EOF
{
  "dateRanges":[{"startDate":"yesterday","endDate":"today"}],
  "metrics":[{"name":"eventCount"},{"name":"sessions"}],
  "dimensions":[{"name":"eventName"}]
}
EOF
)

resp=$(curl -sS -X POST \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "https://analyticsdata.googleapis.com/v1beta/properties/$GA4_PROPERTY_ID:runReport")

signups=$(echo "$resp" | jq --arg ev "$SIGNUP_EVENT" \
  '[.rows[]? | select(.dimensionValues[0].value == $ev) | .metricValues[0].value | tonumber] | add // 0')
sessions=$(echo "$resp" | jq '[.rows[]?.metricValues[1].value | tonumber] | add // 0')

echo "{\"ts\":\"$now_iso\",\"signal\":\"ga4_signups_24h\",\"value\":$signups,\"raw\":{\"event\":\"$SIGNUP_EVENT\"}}" >> "$OBS_FILE"
echo "{\"ts\":\"$now_iso\",\"signal\":\"ga4_sessions_24h\",\"value\":$sessions,\"raw\":{}}" >> "$OBS_FILE"

echo "[ga4] signups_24h=$signups sessions_24h=$sessions"
