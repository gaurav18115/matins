#!/usr/bin/env bash
# .continuity/observe/gsc.sh — Search Console: impressions, clicks, CTR (last 28d)
#
# Required env:
#   GSC_SITE_URL            — e.g. "sc-domain:niptao.app" or "https://niptao.app/"
#   GOOGLE_APPLICATION_CREDENTIALS — SA JSON with the SA added as a user on the
#                                    GSC property (Restricted role is enough)
#
# Output: three JSONL rows
#   - gsc_impressions_28d
#   - gsc_clicks_28d
#   - gsc_top10_ctr_28d (avg CTR across rows where position <= 10)

set -euo pipefail

: "${GSC_SITE_URL:?GSC_SITE_URL is required}"
: "${GOOGLE_APPLICATION_CREDENTIALS:?GOOGLE_APPLICATION_CREDENTIALS path required}"

OBS_FILE="${OBS_FILE:-.continuity/observations.jsonl}"
mkdir -p "$(dirname "$OBS_FILE")"

now_iso="$(python3 -c 'import datetime; print(datetime.datetime.utcnow().isoformat()+"Z")')"

# Compute date window (28 days ending yesterday).
end_date=$(python3 -c "import datetime; print((datetime.date.today() - datetime.timedelta(days=1)).isoformat())")
start_date=$(python3 -c "import datetime; print((datetime.date.today() - datetime.timedelta(days=29)).isoformat())")

access_token=$(python3 - <<'PY'
import os
from google.oauth2 import service_account
import google.auth.transport.requests
creds = service_account.Credentials.from_service_account_file(
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"],
    scopes=["https://www.googleapis.com/auth/webmasters.readonly"],
)
creds.refresh(google.auth.transport.requests.Request())
print(creds.token)
PY
)

# URL-encode the site URL for the API path.
site_enc=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote('$GSC_SITE_URL', safe=''))")

payload=$(cat <<EOF
{
  "startDate":"$start_date",
  "endDate":"$end_date",
  "dimensions":["query","page"],
  "rowLimit":1000
}
EOF
)

resp=$(curl -sS -X POST \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "https://searchconsole.googleapis.com/webmasters/v3/sites/$site_enc/searchAnalytics/query")

impressions=$(echo "$resp" | jq '[.rows[]?.impressions] | add // 0')
clicks=$(echo "$resp" | jq '[.rows[]?.clicks] | add // 0')
top10_ctr=$(echo "$resp" | jq '
  [.rows[]? | select(.position <= 10) | select(.impressions > 0) | (.clicks / .impressions)] as $ctrs
  | if ($ctrs | length) > 0 then (($ctrs | add) / ($ctrs | length)) else 0 end
')

echo "{\"ts\":\"$now_iso\",\"signal\":\"gsc_impressions_28d\",\"value\":$impressions,\"raw\":{}}" >> "$OBS_FILE"
echo "{\"ts\":\"$now_iso\",\"signal\":\"gsc_clicks_28d\",\"value\":$clicks,\"raw\":{}}" >> "$OBS_FILE"
echo "{\"ts\":\"$now_iso\",\"signal\":\"gsc_top10_ctr_28d\",\"value\":$top10_ctr,\"raw\":{}}" >> "$OBS_FILE"

echo "[gsc] impressions_28d=$impressions clicks_28d=$clicks top10_ctr=$top10_ctr"
