#!/usr/bin/env bash
# .continuity/observe/stripe.sh — failed charges + MRR change (last 24h)
#
# Required env:
#   STRIPE_API_KEY    — Stripe restricted key (read scope on charges, subscriptions)
#
# Output: two JSONL rows
#   - stripe_failed_charges_pct_24h   (failed / total charges %)
#   - stripe_active_subscriptions     (snapshot count)

set -euo pipefail

: "${STRIPE_API_KEY:?STRIPE_API_KEY is required}"

OBS_FILE="${OBS_FILE:-.continuity/observations.jsonl}"
mkdir -p "$(dirname "$OBS_FILE")"

now_iso="$(python3 -c 'import datetime; print(datetime.datetime.utcnow().isoformat()+"Z")')"
since_ts=$(( $(date +%s) - 86400 ))

# Pull charges from the last 24h, paginated.
total=0
failed=0
starting_after=""
while : ; do
  url="https://api.stripe.com/v1/charges?limit=100&created[gte]=$since_ts"
  [ -n "$starting_after" ] && url="$url&starting_after=$starting_after"
  resp=$(curl -sS -u "$STRIPE_API_KEY:" "$url")
  count=$(echo "$resp" | jq '.data | length')
  total=$((total + count))
  failed=$((failed + $(echo "$resp" | jq '[.data[] | select(.status == "failed")] | length')))
  has_more=$(echo "$resp" | jq -r '.has_more')
  if [ "$has_more" != "true" ] || [ "$count" -eq 0 ]; then break; fi
  starting_after=$(echo "$resp" | jq -r '.data[-1].id')
done

if [ "$total" -gt 0 ]; then
  pct=$(python3 -c "print(round(${failed} / ${total} * 100, 2))")
else
  pct=0
fi

# Active subscription count (snapshot).
subs_resp=$(curl -sS -u "$STRIPE_API_KEY:" "https://api.stripe.com/v1/subscriptions?status=active&limit=1")
active_subs=$(echo "$subs_resp" | jq '.total_count // (.data | length) // 0')

echo "{\"ts\":\"$now_iso\",\"signal\":\"stripe_failed_charges_pct_24h\",\"value\":$pct,\"raw\":{\"failed\":$failed,\"total\":$total}}" >> "$OBS_FILE"
echo "{\"ts\":\"$now_iso\",\"signal\":\"stripe_active_subscriptions\",\"value\":$active_subs,\"raw\":{}}" >> "$OBS_FILE"

echo "[stripe] failed_pct_24h=$pct% active_subs=$active_subs (failed=$failed of $total)"
