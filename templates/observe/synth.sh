#!/usr/bin/env bash
# .continuity/observe/synth.sh — synthesize task suggestions from recent observations
#
# Reads:
#   .continuity/observations.jsonl    — append-only telemetry
#   .continuity/thresholds.yaml       — red/yellow/green bands
#
# Writes (to stdout):
#   Task suggestions in the exact MATINS.md Active Tasks format, for any
#   signal currently in the red band.
#
# The agent reviews the output, deduplicates against existing tasks, and
# pastes adopted suggestions into ## Active Tasks.
#
# Exit codes:
#   0  — synth ran (with or without suggestions)
#   1  — config or input file missing

set -euo pipefail

OBS_FILE="${OBS_FILE:-.continuity/observations.jsonl}"
THRESH_FILE="${THRESH_FILE:-.continuity/thresholds.yaml}"
VENTURE="${VENTURE:-$(basename "$PWD")}"
TODAY="$(date +%Y-%m-%d)"
TOMORROW="$(python3 -c "import datetime; print((datetime.date.today() + datetime.timedelta(days=1)).isoformat())")"

[ -f "$OBS_FILE" ] || { echo "synth: no observations yet at $OBS_FILE" >&2; exit 0; }
[ -f "$THRESH_FILE" ] || { echo "synth: missing $THRESH_FILE" >&2; exit 1; }

python3 - "$OBS_FILE" "$THRESH_FILE" "$VENTURE" "$TODAY" "$TOMORROW" <<'PY'
import json, sys, re
from collections import defaultdict
try:
    import yaml
except ImportError:
    sys.stderr.write("synth: pyyaml required (pip install pyyaml)\n")
    sys.exit(1)

obs_path, thresh_path, venture, today, tomorrow = sys.argv[1:6]

# Latest value per signal
latest = {}
with open(obs_path) as f:
    for line in f:
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        latest[row["signal"]] = row

with open(thresh_path) as f:
    cfg = yaml.safe_load(f)

signals = cfg.get("signals", {})

def parse_band(spec):
    """Parse '<0.5%' / '0.5%-1%' / '>1%' into (op, low, high)."""
    spec = spec.strip().replace("%", "")
    if spec.startswith("<"):
        return ("lt", float(spec[1:]))
    if spec.startswith(">"):
        return ("gt", float(spec[1:]))
    if "-" in spec:
        lo, hi = spec.split("-", 1)
        return ("range", float(lo), float(hi))
    if spec.startswith("="):
        return ("eq", float(spec[1:]))
    try:
        return ("eq", float(spec))
    except ValueError:
        return None

def in_band(value, spec):
    p = parse_band(spec)
    if p is None: return False
    if p[0] == "lt":   return value <  p[1]
    if p[0] == "gt":   return value >  p[1]
    if p[0] == "eq":   return value == p[1]
    if p[0] == "range":return p[1] <= value <= p[2]
    return False

def band_of(signal_name, value, thresh):
    if isinstance(thresh, dict):
        if "red"    in thresh and in_band(value, thresh["red"]):    return "red"
        if "yellow" in thresh and in_band(value, thresh["yellow"]): return "yellow"
        if "green"  in thresh and in_band(value, thresh["green"]):  return "green"
        # baseline-relative
        if "baseline" in thresh:
            base = thresh["baseline"]
            if base == "auto":
                # caller should pass it; here we skip
                return "unknown"
            if "red_if_below_pct" in thresh:
                if value < base * (thresh["red_if_below_pct"] / 100):
                    return "red"
            if "red_if_drop_pct" in thresh:
                if value < base * (1 - thresh["red_if_drop_pct"] / 100):
                    return "red"
    return "unknown"

# Emit one Active-Tasks block per red-band signal.
emitted = 0
for sig, thresh in signals.items():
    if sig not in latest:
        continue
    value = latest[sig]["value"]
    band  = band_of(sig, value, thresh)
    if band != "red":
        continue
    emitted += 1
    print(f"- **Task:** Investigate red-band on {sig} (current={value})")
    print(f"- **Venture:** {venture}")
    print(f"- **Owner:** agent")
    print(f"- **Deadline:** {tomorrow}")
    print(f"- **Status:** TODO")
    print(f"- **Tracker:** auto-synth-{today}-{sig}")
    print(f"- **Last Verified:** {today}")
    print(f"- **Next Check:** {tomorrow}")
    print(f"- **Success Criteria:** {sig} back to green band OR root cause documented in ADR")
    print(f"- **Outcome:**")
    print()

if emitted == 0:
    print(f"# synth: no red-band signals as of {today}. All clear.", file=sys.stderr)
else:
    print(f"# synth: emitted {emitted} red-band task suggestion(s)", file=sys.stderr)
PY
