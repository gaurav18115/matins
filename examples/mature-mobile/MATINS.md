# MATINS.md — TideMap (example mature Mobile App, ~30 days of cycles)

> Spec: <https://github.com/gaurav18115/matins> (v0.2.0)
> This is what `MATINS.md` looks like for a React Native / Expo mobile app
> after about a month of `/loop run matins` cycles. Real-feeling but fictitious.

## Identity

**Project:** TideMap — tide & surf forecast app for the Indian coast (Goa, Kerala, Karnataka)
**Domain Profile(s):** Mobile App (primary), B2B SaaS (web-admin secondary)
**Live URL:** https://tidemap.example (web admin) · Play Store + TestFlight (mobile)
**Repo:** github.com/example/tidemap
**Stack:** Expo SDK 53 + React Native 0.78 + TypeScript + Supabase Postgres (Mumbai) + Sentry Mobile + EAS Build + Vercel (web admin) + Doppler
**Operator:** Riya Iyer <riya@tidemap.example>
**Mission:** 10,000 weekly active surf users + 50 surf-school B2B accounts by end of monsoon (Sept 2026). Crash rate <0.5%. Onboarding <45 seconds.

## This Week — 2026-W21 (2026-05-25)

1. **Ship widget for iOS lock-screen tide reading (TM-238)** — `tracker:GH#238` — `since:2026-05-22` — last QA pass before TestFlight push
2. **Fix Android offline-tile cache invalidation** — `tracker:GH#241` — `since:2026-05-24` — Crashlytics flagged 1-2★ reviews mentioning blank map
3. **GA4 → KeyEvents migration** — `tracker:GH#235` — `since:2026-05-15` — funnel analysis unblocked once done

## Active Tasks

- **Task:** Ship iOS lock-screen tide widget (WidgetKit, refresh every 30 min)
- **Venture:** TideMap
- **Owner:** agent
- **Deadline:** 2026-05-28
- **Status:** IN_PROGRESS
- **Tracker:** GH#238
- **Last Verified:** 2026-05-26
- **Next Check:** 2026-05-27
- **Success Criteria:** Widget builds clean in EAS, renders on iOS 17+ lock screen, tide value matches `/api/tide` payload within 30min freshness, Sentry mobile shows 0 widget-extension crashes over 24h post-TestFlight
- **Outcome:**

- **Task:** Fix Android offline-tile cache invalidation (red-band auto-task from review-spike monitor)
- **Venture:** TideMap
- **Owner:** agent
- **Deadline:** 2026-05-27
- **Status:** IN_PROGRESS
- **Tracker:** auto-synth-2026-05-24-play-1-2-star-spike + GH#241
- **Last Verified:** 2026-05-26
- **Next Check:** 2026-05-26 EOD
- **Success Criteria:** play_store_1_2_star_24h back to 0, root cause documented (cache-key collision on tile-zoom change), regression test in Detox suite
- **Outcome:** Reproduced — tile cache keyed only on lat/lng, not zoom. Fix in progress, target ship to staged 10% rollout by 2026-05-26 22:00 IST.

- **Task:** GA4 conversion event migration (5 events → Key Events via Admin API)
- **Venture:** TideMap
- **Owner:** agent
- **Deadline:** 2026-05-30
- **Status:** TODO
- **Tracker:** GH#235
- **Last Verified:** 2026-05-25
- **Next Check:** 2026-05-26
- **Success Criteria:** `sign_up`, `forecast_view`, `tide_alert_subscribe`, `surf_school_lead`, `paid_upgrade` all marked as Key Events in GA4 Admin. Service account `claude-analytics@...` needs `analytics.edit` scope.
- **Outcome:**

## Backlog

- **Task:** Replace expo-notifications with native push-only (FCM + APNS) — current stack is double-paying for the Expo push service
- **Venture:** TideMap
- **Owner:** agent
- **Priority:** P1
- **Notes:** Estimated $40/mo saved + lower latency. Touches onboarding flow — coordinate with surf-school B2B onboarding refresh.

- **Task:** Surf-school admin web — bulk-upload of student emails for SMS tide alerts
- **Venture:** TideMap
- **Owner:** agent
- **Priority:** P2
- **Notes:** Two schools requested in user interviews. Twilio India OTP needed first (see Blockers).

- **Task:** Live wave-height overlay on map (data: ECMWF WW3 model, hourly refresh)
- **Venture:** TideMap
- **Owner:** agent
- **Priority:** P2
- **Notes:** Differentiator vs Magicseaweed but data licensing TBD.

## Blockers

- **Item:** Twilio India OTP delivery for surf-school SMS alerts
- **Since:** 2026-05-12
- **Why:** TRAI DLT registration incomplete — entity registration approved 2026-05-04 but template registration pending vendor review.
- **Unblock:** Either (a) complete DLT template registration with Twilio support (ETA 2-4 weeks from 2026-05-12), OR (b) switch IN-bound SMS to MSG91 (pre-DLT-approved, ~2 days setup).
- **Owner of unblock:** human-Riya (provider decision — cost vs timeline)

## Decisions Log

> In a real project, these are markdown links to ADR files in `docs/decisions/`. Listed as plain text here because this MATINS.md is illustrative.

- `0001-name-tidemap` — Accepted 2026-04-26
- `0002-supabase-mumbai-region` — Accepted 2026-04-29
- `0003-expo-sdk-53-not-bare` — Accepted 2026-05-02
- `0004-eas-build-not-codemagic` — Accepted 2026-05-05
- `0005-doppler-over-eas-secrets` — Accepted 2026-05-09
- `0006-android-rollout-always-100pct` — Accepted 2026-05-14
- `0007-no-expo-push-future` — Proposed 2026-05-25

## Decisions & Constraints

### Standing Decisions
- Default branch for agent work: `dev`. Never push to `main`.
- Android prod rollout: **always 100% (`releaseStatus=completed`)** — no staged 10/25/50. Crash rate must be ≤0.5% (rolling 7d) to ship. See ADR 0006.
- iOS rollout: phased via App Store Connect, default 7-day phased release.
- Never run schema changes against Supabase prod during peak surf hours (05:00–08:00 IST or 16:00–19:00 IST).
- Notify Riya on Telegram `#tidemap-ops` on: crash rate >0.5%, P0 Sentry, 1-2★ review spike (>=2 in 24h), Play Store rollout halt, deploy failure, Twilio OTP delivery <90%.

### Constraints
- **Off-limits without approval:** Production deploys (web admin via Vercel preview→prod promotion only by Riya), App Store / Play Store submissions, customer push notifications to real users, Supabase prod schema changes, secret rotation, customer SMS sends (Twilio).

## Skills & Connectors

### Active Connectors (signals)
- **Sentry mobile** — `tidemap-android`, `tidemap-ios` projects (every cycle)
- **Sentry web** — admin project (every 6 cycles)
- **Play Console** — crash rate, ANR, installs, 1-2★ reviews via androidpublisher API (every cycle)
- **App Store Connect** — phased rollout state, crash signatures via App Store Connect API (every 6 cycles)
- **GA4** — funnels via Data API (every 6 cycles)
- **Vercel** — admin web runtime + errors (every cycle)
- **Supabase** — RLS denies + slow queries (every cycle)
- **Twilio** — OTP delivery % from status callback log (every 6 cycles)
- **Telegram admin bot** — `#tidemap-ops` channel

### Available Skills
- `eas-build-watch` — poll Android/iOS builds, attach to GH Release
- `play-ramp` — Play Console rollout fraction control
- `supabase` skill family
- `vercel:*` family — preview deploys (Riya gates prod)
- `telegram-notify`
- `claude-api` — Anthropic SDK paths used for tide-narrative LLM features

## Last Run

**Timestamp:** 2026-05-26T08:22:14Z
**Cycle ID:** 2026-05-26-0822
**Duration:** 9 minutes
**Mode:** Scheduled (/loop self-paced)
**Tasks Attempted:** 3
**Tasks Completed:** 1
**Tasks Failed:** 0

### Actions Taken
1. [DONE] Bisected Android offline-tile cache bug to commit `4f1c9a2` (2026-05-21 cache-refactor). Tile-cache key now includes zoom level. Detox regression test added. PR #244 opened against dev.
2. [IN_PROGRESS] iOS widget — EAS build green, TestFlight upload pending Apple processing.
3. [TODO → blocked-soft] GA4 KeyEvents migration — needs SA scope change on GCP. Pinged Riya for `analytics.edit` grant.

### Blockers
- See ## Blockers — Twilio India DLT (unchanged).

### New Lessons
- See ## Lessons → "Mobile tile-cache keys must include every dimension that affects the rendered output."

### Notes for Next Run
- Check TestFlight processing for widget build.
- If Riya hasn't responded on GA4 scope by 2026-05-26 18:00, soft-park GA4 migration to Backlog.

## Lessons

- **Lesson:** Mobile tile-cache keys must include every dimension that affects the rendered output — lat/lng alone is not enough when zoom changes the tile content.
- **Date:** 2026-05-26
- **Context:** GH#241 spiked 1-2★ reviews ("map blank below zoom 14"). Tile cache was keyed on `(lat, lng)`. After zoom changed, stale tiles were served. Lookup needs `(lat, lng, zoom, layer)`.
- **Promoted to:** ADR-pending (`0008-tile-cache-key-schema.md` draft), code comment in `src/lib/cache/tile-cache.ts:46`.
- **Action:** Audit other cache layers (forecast cache, wave-overlay cache) for similar incomplete-key bugs.

- **Lesson:** Synth's red-band detection on Play Store 1-2★ reviews is high-signal — the cache bug was visible in user reviews 18 hours before the Detox suite would have caught it (suite runs weekly).
- **Date:** 2026-05-24
- **Context:** Auto-task fired at review #2 of the spike. By the time three more came in, agent had reproduced + bisected.
- **Promoted to:** Standing Decisions (notify-on-1-2-star moved from yellow to red band).
- **Action:** Keep the threshold as red. Move Detox suite cadence from weekly to per-deploy on staged rollout.

- **Lesson:** Always-100% rollout (ADR 0006) caught its first stress test on the cache bug — couldn't hide a 1-2★ spike behind staged-rollout cohort filtering. Forced fast response.
- **Date:** 2026-05-25
- **Context:** With staged rollout, a 1% cohort can hide a regression that hits 30% of users in that cohort. With 100% rollout, all users see it immediately and the signal is unambiguous.
- **Promoted to:** ADR 0006 (already accepted).
- **Action:** None — the policy paid off.

## Retro Log

### 2026-W21 retro (2026-05-23)
- **Shipped:** Forecast-narrative LLM feature (PR #232), Sentry Android source-map upload automation (PR #234), iOS widget skeleton (PR #237).
- **Slipped:** None — clean week.
- **Promote:** ADR 0005 (Doppler over EAS secrets) — was a pending lesson, now formalized.
- **Numbers moved:** weekly active users 4,210 → 4,890 (+16%), crash rate 0.41% → 0.34%, App Store rating 4.5 → 4.6.

### 2026-W20 retro (2026-05-16)
- **Shipped:** Cache layer refactor (PR #228) — *which silently introduced the tile-cache bug now in GH#241*, surf-school B2B onboarding flow (PR #229), Hindi locale (PR #231).
- **Slipped:** Live wave-height overlay (deferred to Backlog — data licensing unresolved).
- **Promote:** Lesson about Hindi numeral rendering in iOS WidgetKit (promoted to CONTRIBUTING.md "i18n gotchas" section).
- **Numbers moved:** Hindi-locale signups: 0 → 412 in week 1 (huge — Hindi was a 6-month-blocked feature). Onboarding completion 62% → 71%.

### 2026-W19 retro (2026-05-09)
- **Shipped:** Stripe billing for B2B tier (PR #220), email digests via Resend (PR #222), GA4 + Clarity instrumentation (PR #224).
- **Slipped:** Twilio OTP for surf-school SMS — DLT-blocked (see Blockers).
- **Promote:** "Twilio India delivery requires DLT — never assume sender works pre-registration" promoted to a CLAUDE.md rule + standing reference doc.
- **Numbers moved:** Stripe MRR 0 → ₹12,400 (first 2 B2B contracts), Resend bounce rate 0.4%.

## History

### 2026-05-26 (Cycle 2026-05-26-0822)
- **Cycle:** 2026-05-26-0822
- **Duration:** 9 min
- **Result:** 1/3 tasks completed (cache-key fix shipped to dev)
- **Actions:** Bisected GH#241 to commit 4f1c9a2, fix in PR #244, Detox regression case added.
- **Lesson:** Cache keys must include every dimension affecting output.

### 2026-05-25 (Cycle 2026-05-25-2231)
- **Cycle:** 2026-05-25-2231
- **Duration:** 5 min
- **Result:** Monday cadence — rewrote ## This Week, ran 14-day staleness check.
- **Actions:** Reset weekly focus on widget + cache-fix + GA4 migration.
- **Lesson:** Always-100% rollout caught first real stress test.

### 2026-05-24 (Cycle 2026-05-24-1547)
- **Cycle:** 2026-05-24-1547
- **Duration:** 4 min
- **Result:** Auto-synth fired (Play Store 1-2★ spike). Created task. Paused other work to investigate.
- **Actions:** Auto-task created for cache bug. Telegram ping to Riya.
- **Lesson:** Synth red-band on Play reviews is high-signal — keep at red.

### 2026-05-23 (Cycle 2026-05-23-1903)
- **Cycle:** 2026-05-23-1903
- **Duration:** 8 min
- **Result:** Friday retro generated. Week shipped clean.
- **Actions:** Retro entry, ADR 0005 formalized.
- **Lesson:** None.

### 2026-05-22 (Cycle 2026-05-22-1102)
- **Cycle:** 2026-05-22-1102
- **Duration:** 12 min
- **Result:** iOS widget PR opened (PR #237). EAS build green.
- **Actions:** WidgetKit skeleton + tide payload integration. Pushed to dev.
- **Lesson:** None.

*[History entries older than 30 days were archived to `archive/MATINS-2026-Q1.md` on the quarterly prune.]*
