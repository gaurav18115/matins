# MATINS.md — RouteAtlas (example mature B2B SaaS, ~30 days of cycles)

> Spec: <https://github.com/gaurav18115/matins> (v0.1.0)
> This is what `MATINS.md` looks like after a month. Bootstrap block is gone.
> Real-feeling but fictitious — names, metrics, repos are illustrative.

## Identity

**Project:** RouteAtlas — last-mile delivery routing SaaS for SMB couriers
**Domain Profile(s):** B2B SaaS
**Live URL:** https://routeatlas.example
**Repo:** github.com/example/routeatlas
**Stack:** Next.js 15 + tRPC + Postgres (Neon) + Vercel + Stripe + Sentry + Doppler
**Operator:** Sam Park <sam@routeatlas.example>
**Mission:** 50 paying SMB courier accounts by end of Q3. Median onboarding to first-route in <10 minutes.

## This Week — 2026-W21 (2026-05-25)

> Rewritten Monday 2026-05-25. Cap: 3.

1. **Ship driver-app push notifications (NTA-142)** — `tracker:GH#142` — `since:2026-05-22` — blocked Friday on iOS APNS cert renewal, unblocked Monday.
2. **Investigate Sentry spike on /api/routes/optimize** — auto-synth task, red since 2026-05-23 14:00, target green by 2026-05-26.
3. **Stripe billing webhook idempotency** — `tracker:GH#138` — `since:2026-05-19`, two near-misses caught this week; ship retry guard before more land.

## Active Tasks

- **Task:** Ship driver-app push notifications (Expo + APNS)
- **Venture:** RouteAtlas
- **Owner:** agent
- **Deadline:** 2026-05-28
- **Status:** IN_PROGRESS
- **Tracker:** GH#142
- **Last Verified:** 2026-05-26
- **Next Check:** 2026-05-27
- **Success Criteria:** Driver receives push within 5s of dispatcher assignment; e2e test green on staging; Sentry mobile project shows 0 unhandled APNS errors over 24h
- **Outcome:**

- **Task:** Investigate Sentry red-band on /api/routes/optimize (current=1.4%, baseline 0.3%)
- **Venture:** RouteAtlas
- **Owner:** agent
- **Deadline:** 2026-05-26
- **Status:** IN_PROGRESS
- **Tracker:** auto-synth-2026-05-23-sentry-routes-optimize
- **Last Verified:** 2026-05-26
- **Next Check:** 2026-05-26 EOD
- **Success Criteria:** sentry_error_rate_24h back to <0.5% on `/api/routes/optimize` OR root cause in `docs/decisions/0007-routes-optimize-retry.md`
- **Outcome:** Bisected to deploy `dpl_a91f...` (2026-05-23 13:42 UTC). Added retry-on-503 for upstream OSRM call, deploying retry guard.

- **Task:** Stripe webhook idempotency — guard against double-processing
- **Venture:** RouteAtlas
- **Owner:** agent
- **Deadline:** 2026-05-27
- **Status:** TODO
- **Tracker:** GH#138
- **Last Verified:** 2026-05-25
- **Next Check:** 2026-05-26
- **Success Criteria:** `stripe_event_id` becomes idempotency key on `processed_events` table; backfill unique constraint; double-processing test in vitest passes
- **Outcome:**

## Backlog

- **Task:** Add `customer.subscription.paused` handler — Stripe pauses are silently dropped today
- **Priority:** P2
- **Notes:** Caught when one trial-converter manually paused via Stripe portal; we kept their access for 4 days. Low-incidence but data-integrity bug.

- **Task:** Refresh /pricing page — competitor (Routific) cut their starter tier last week
- **Priority:** P2
- **Notes:** GSC shows our `/pricing` rank dropped from 7 → 12 for "delivery routing software" since 2026-05-15.

- **Task:** OnboardingDrip email cadence — currently 1/3/7 day; A/B test 1/2/4
- **Priority:** P3
- **Notes:** From Friday retro 2026-W20.

## Blockers

- **Item:** iOS TestFlight builds blocked on APNS cert renewal
- **Since:** 2026-05-22
- **Why:** Push cert expired; renewed via Apple Developer portal but new cert hasn't propagated to APNS sandbox.
- **Unblock:** Wait for 24h propagation (per Apple docs) OR re-create the certificate from scratch with the new key.
- **Owner of unblock:** agent — propagation window ends 2026-05-26 13:00 UTC; if not green by then, re-create.

## Decisions Log

> In a real project, these are markdown links to actual ADR files in `docs/decisions/`. Listed as plain text here because this `MATINS.md` is illustrative — the ADR files don't exist.

- `0001-name-routeatlas` — Accepted 2026-04-28
- `0002-postgres-over-mongodb` — Accepted 2026-05-01
- `0003-trpc-over-rest` — Accepted 2026-05-04
- `0004-vercel-cron-retired` — Accepted 2026-05-09 (after the 99.7% incident)
- `0005-expo-for-driver-app` — Accepted 2026-05-12
- `0006-doppler-over-vercel-env` — Accepted 2026-05-18
- `0007-routes-optimize-retry` — Proposed 2026-05-26

## Decisions & Constraints

### Standing Decisions
- Default branch for agent work: `dev`. Never push to `main`.
- Never re-enable Vercel crons without an audit per ADR 0004.
- Conventional commits required.
- After every feature ships to `dev`: vitest unit + Playwright on touched flow + cross-flow regression on `/dashboard`.
- Notify Sam on Slack `#routeatlas-alerts` on: Sentry P0, Vercel runtime spike (>5 GB-Hrs/24h), Stripe failed-charge rate >5%, deploy failure, BLOCKED task that needs human.

### Constraints
- **Off-limits without approval:** Prod deploys (use Vercel preview, then Sam promotes), prod DB schema changes (use shadow DB + diff), customer email sends, secret rotation.

## Skills & Connectors

### Active Connectors (signals)
- **Sentry** — `routeatlas-web`, `routeatlas-mobile` projects (every cycle)
- **Vercel** — runtime cost, function errors (every cycle)
- **GA4** — signups, activation, paid conversions (every 6 cycles)
- **Search Console** — `sc-domain:routeatlas.example` (every 6 cycles)
- **Postgres (Neon)** — slow queries, conn count, RLS denies (every cycle)
- **Stripe** — failed charges, active subs (every 6 cycles)
- **Slack admin** — `#routeatlas-alerts` channel

### Available Skills
- supabase (for Neon), vercel:* family, claude-api, google-analytics + google-search-console (MCP), slack-notify

## Last Run

**Timestamp:** 2026-05-26T08:14:22Z
**Cycle ID:** 2026-05-26-0814
**Duration:** 11 minutes
**Mode:** Scheduled (/loop self-paced)
**Tasks Attempted:** 3
**Tasks Completed:** 1
**Tasks Failed:** 0

### Actions Taken
1. [DONE] Bisected Sentry spike on `/api/routes/optimize` to deploy `dpl_a91f...`. Wrote ADR 0007. Pushed retry guard to `dev`.
2. [IN_PROGRESS] Driver-app push notifications — APNS cert propagation still pending. Set Next Check 2026-05-26 13:00 UTC.
3. [TODO → IN_PROGRESS] Stripe webhook idempotency — added migration, vitest case scaffolded, paused for Sentry P0.

### Blockers
- iOS TestFlight blocked on APNS cert propagation (see ## Blockers).

### New Lessons
- See ## Lessons → "Sentry red-band auto-tasks need a baseline-aware threshold."

### Notes for Next Run
- Check APNS propagation at 13:00 UTC.
- If retry guard didn't move error rate by next signal pull, escalate to ADR review.

## Lessons

- **Lesson:** Sentry red-band auto-tasks need a baseline-aware threshold for endpoint-level rates.
- **Date:** 2026-05-26
- **Context:** synth flagged `/api/routes/optimize` at 1.4% — but the project-wide threshold is 1%, and this endpoint had been historically at 0.3%. By the time the project-wide rate moved, the endpoint had been bad for ~3 hours.
- **Promoted to:** `templates/observe/sentry.sh` (PR to add per-route bands), thresholds.yaml updated locally with `sentry_error_rate_route_5xx_per_endpoint`.
- **Action:** Add per-route threshold key. Re-run synth.

- **Lesson:** Conventional commits + `## History` are a search-friendly audit trail. `git log --all --grep="auto-synth" -- MATINS.md` shows every signal-driven cycle.
- **Date:** 2026-05-19
- **Context:** Sam asked "when did we first see the Stripe near-miss?" — found it in 30 seconds via the log.
- **Promoted to:** CONTRIBUTING.md note in repo about how to query MATINS history.
- **Action:** None — pattern is working.

- **Lesson:** Don't re-enable Vercel crons without per-route audit (timeouts, recursion, missing auth).
- **Date:** 2026-05-09
- **Context:** Pre-RouteAtlas, sister project burned 99.7% team compute on a runaway cron.
- **Promoted to:** ADR 0004 (Vercel cron retired), CLAUDE.md rule.
- **Action:** Cron handlers stay off until paid plan + per-route audit. Use Vercel Functions invoked from Inngest/Trigger.dev if recurring work is needed.

## Retro Log

### 2026-W20 retro (2026-05-23)
- **Shipped:** Stripe near-miss fix (PR #134), driver-app login flow (PR #135), 2 SEO content posts (PR #137 + #139).
- **Slipped:** Push notifications (blocked Friday on cert renewal — see ## Blockers).
- **Promote:** "Conventional commits + History as audit trail" lesson promoted to CONTRIBUTING note.
- **Numbers moved:** signups 7 → 11/day (+57%), Sentry rate 0.4% → 0.31%, Stripe failed-charge 3.1% → 2.8%, GSC top-10 CTR 4.2% → 4.5%.

### 2026-W19 retro (2026-05-16)
- **Shipped:** Onboarding flow rewrite (PR #128, A/B 50/50). Doppler migration complete.
- **Slipped:** None — light week, mostly catching up from PPAI cron incident.
- **Promote:** ADR 0006 (Doppler over Vercel env) from a recurring "where do I put this secret" lesson.
- **Numbers moved:** activation rate 41% → 48% (onboarding A/B leg B winning).

### 2026-W18 retro (2026-05-09)
- **Shipped:** Cron retirement (ADR 0004), routes API rate-limit fix, onboarding video.
- **Slipped:** Driver-app skeleton — Expo prebuild was painful, deferred to W19.
- **Promote:** ADR 0004. Also a CLAUDE.md rule: "Never re-add Vercel crons without per-route audit."
- **Numbers moved:** Vercel runtime $34/day → $4/day (-88%). Sentry rate 1.2% → 0.4% (cron crash trail cleared).

## History

### 2026-05-26 (Cycle 2026-05-26-0814)
- **Cycle:** 2026-05-26-0814
- **Duration:** 11 min
- **Result:** 1/3 tasks completed (Sentry RCA shipped)
- **Actions:** Bisected /api/routes/optimize spike to dpl_a91f, ADR 0007 drafted, retry guard pushed.
- **Lesson:** Per-route Sentry thresholds needed.

### 2026-05-25 (Cycle 2026-05-25-2104)
- **Cycle:** 2026-05-25-2104
- **Duration:** 4 min
- **Result:** Monday cadence: rewrote ## This Week, ran 14-day staleness check (none stale).
- **Actions:** Reset weekly focus. Onboarding A/B winner promoted to default.
- **Lesson:** None.

### 2026-05-25 (Cycle 2026-05-25-0612)
- **Cycle:** 2026-05-25-0612
- **Duration:** 8 min
- **Result:** 2/2 tasks completed
- **Actions:** Stripe near-miss test added, onboarding A/B leg B promoted to 100%.
- **Lesson:** None.

### 2026-05-23 (Cycle 2026-05-23-1408)
- **Cycle:** 2026-05-23-1408
- **Duration:** 3 min
- **Result:** Auto-synth triggered red-band; created task; agent paused other work to investigate.
- **Actions:** Detected Sentry rate jump on /api/routes/optimize. Slack ping sent.
- **Lesson:** Synth correctly preempted lower-priority backlog work — keep this behavior.

### 2026-05-22 (Cycle 2026-05-22-1133)
- **Cycle:** 2026-05-22-1133
- **Duration:** 7 min
- **Result:** Driver-app login PR opened. APNS cert expired → BLOCKED for renewal.
- **Actions:** Renewed cert via Apple portal, opened ## Blockers entry.
- **Lesson:** None.

*[History entries older than 30 days were archived to `archive/MATINS-2026-Q1.md` on the quarterly prune.]*
