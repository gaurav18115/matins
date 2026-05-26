#!/usr/bin/env bash
# .continuity/observe/supabase.sh — Postgres health (slow queries, RLS denies, conn count)
#
# Required env:
#   DATABASE_URL            — Postgres connection string (read-only role recommended)
#
# Output: three JSONL rows
#   - pg_slow_queries_5m      (count of queries running > 5s)
#   - pg_active_connections   (pg_stat_activity rows)
#   - pg_rls_denies_24h       (if RLS audit logging enabled; else 0)
#
# Notes:
#   For Supabase, get DATABASE_URL from Project Settings → Database → Connection
#   string (pooler, transaction mode). Create a dedicated read-only role:
#     CREATE ROLE matins_observer LOGIN PASSWORD '...';
#     GRANT pg_monitor TO matins_observer;

set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"

OBS_FILE="${OBS_FILE:-.continuity/observations.jsonl}"
mkdir -p "$(dirname "$OBS_FILE")"

now_iso="$(python3 -c 'import datetime; print(datetime.datetime.utcnow().isoformat()+"Z")')"

slow_queries=$(psql "$DATABASE_URL" -At -c "
  SELECT COUNT(*) FROM pg_stat_activity
  WHERE state = 'active' AND now() - query_start > interval '5 seconds';
" 2>/dev/null || echo 0)

active_conns=$(psql "$DATABASE_URL" -At -c "
  SELECT COUNT(*) FROM pg_stat_activity WHERE state IS NOT NULL;
" 2>/dev/null || echo 0)

# RLS denies — only available if you've set up an audit_log table tracking them.
# Skip silently if missing.
rls_denies=$(psql "$DATABASE_URL" -At -c "
  SELECT COUNT(*) FROM audit_log
  WHERE event = 'rls_deny' AND created_at > now() - interval '24 hours';
" 2>/dev/null || echo 0)

echo "{\"ts\":\"$now_iso\",\"signal\":\"pg_slow_queries_5m\",\"value\":$slow_queries,\"raw\":{}}" >> "$OBS_FILE"
echo "{\"ts\":\"$now_iso\",\"signal\":\"pg_active_connections\",\"value\":$active_conns,\"raw\":{}}" >> "$OBS_FILE"
echo "{\"ts\":\"$now_iso\",\"signal\":\"pg_rls_denies_24h\",\"value\":$rls_denies,\"raw\":{}}" >> "$OBS_FILE"

echo "[supabase] slow_queries=$slow_queries active_conns=$active_conns rls_denies_24h=$rls_denies"
