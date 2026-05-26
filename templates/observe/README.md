# `.continuity/observe/`

Starter shell scripts that pull real-world signals into `.continuity/observations.jsonl`. Each script writes one JSONL row per run.

## How they fit in

```
.continuity/
├── thresholds.yaml          # red/yellow/green bands per signal
├── observations.jsonl       # append-only telemetry (gitignored)
└── observe/
    ├── sentry.sh
    ├── ga4.sh
    ├── gsc.sh
    ├── vercel.sh
    ├── supabase.sh
    ├── stripe.sh
    ├── synth.sh             # diffs latest vs prior, emits task suggestions
    └── README.md            # this file
```

Full spec: <https://github.com/gaurav18115/matins/blob/main/docs/ANALYTICS.md>

## Setup

1. Copy the scripts you need into your project's `.continuity/observe/` directory.
2. Edit each script's credential section (top of file) — env-var names are documented in comments.
3. `chmod +x .continuity/observe/*.sh`.
4. Add `.continuity/observations.jsonl` to `.gitignore`.
5. Write `.continuity/thresholds.yaml` (see [`thresholds.example.yaml`](thresholds.example.yaml)).

The agent will run `bash .continuity/observe/<critical>.sh` every cycle (red-band signals) and `bash .continuity/observe/*.sh && bash .continuity/observe/synth.sh` every 6 cycles (full pull + synth).

## Conventions

Each observe script:

- Takes no arguments.
- Reads credentials from env vars (documented at the top of the script).
- Writes one JSONL row to `.continuity/observations.jsonl`:
  ```json
  {"ts":"<ISO8601>","signal":"<name>","value":<number>,"band":"green|yellow|red","raw":{...}}
  ```
- Exits 0 on success, non-zero on credential/network failure. The agent does not treat a single failure as a signal change — it logs and retries next cycle.
- Is idempotent — running it twice in a row produces two rows with similar values, never duplicates a "task created" side effect.

The `band` field is computed by reading `.continuity/thresholds.yaml` — if you skip it in the script, `synth.sh` will fill it in. Either is fine.

## Writing your own

If you need a signal we don't ship (Datadog, Honeycomb, PostHog, Mixpanel, Crashlytics, App Store Connect, …), copy any existing script as a starting point and adjust. PRs welcome — see [CONTRIBUTING.md](../../CONTRIBUTING.md).

## Dependencies

The shipped scripts use only `curl`, `jq`, `date`, and `python3` (for ISO timestamps where `date` differs across macOS/Linux). No language SDKs required. If your script needs a heavier client (e.g. `gcloud`, `aws`, `vercel`), document it at the top.
