# Domain Profiles

A domain profile is a starter pack of recurring tasks the agent seeds into `## Active Tasks` on first bootstrap, based on what kind of project it's looking at. Profiles are not exclusive — a project can match more than one.

This catalog ships with 7 profiles. New profiles are welcome (see [CONTRIBUTING.md](../CONTRIBUTING.md)).

---

## 1. B2B SaaS

**Signals:** customer accounts, login / auth, dashboards, billing, recurring revenue, sales pipeline, multi-tenant data.

**Starter tasks:**
- Verify health endpoints + uptime monitoring active
- Audit cron jobs for cost (Vercel GB-Hrs, Lambda invocations) — *unbounded crons have killed projects, see [SECURITY.md](../SECURITY.md)*
- Run regression suite (unit + e2e on golden path)
- Review lead pipeline, surface stale prospects (>14 days no touch)
- Audit production error rate (Sentry, runtime logs) for last 24h
- Check billing webhook integrity (Stripe / Razorpay events delivered + processed)
- Refresh demo data + onboarding flow

**Primary observe scripts:** `sentry.sh`, `vercel.sh`, `ga4.sh`, `stripe.sh`, `supabase.sh`

**Red-band auto-task triggers:**
- Sentry error rate >1% → P0 fix task
- Vercel GB-Hrs >20/24h → cron / route audit task
- GA4 signups <1/3 of 30-day rolling median → outreach task
- Stripe failed-charge rate >5% → billing health task

---

## 2. Marketing / Landing Site

**Signals:** static-first, low backend, SEO-driven, conversion-focused, often a small number of routes.

**Starter tasks:**
- Audit Core Web Vitals (Lighthouse on prod, top 5 routes)
- Check Search Console for indexing issues + recent ranking changes
- Refresh the top 3 SEO landing pages (content recency)
- Verify analytics events firing (GA4, Plausible, Umami)
- Check broken links, 404s, sitemap.xml validity
- Run accessibility audit (axe-core)

**Primary observe scripts:** `ga4.sh`, `gsc.sh`, `lighthouse.sh`, `links.sh`

**Red-band auto-task triggers:**
- CTR drop >20% on a top-10 page → rewrite task
- New keyword appears in top-20 (rank 11–20) → content-expansion task
- LCP regress >25% → performance task
- 404 in sitemap → broken-link task

---

## 3. Mobile App (React Native / Expo / Flutter)

**Signals:** Expo / React Native or Flutter, EAS / Codemagic builds, Play Store / App Store, in-app crash reporting (Sentry, Firebase Crashlytics, Bugsnag).

**Starter tasks:**
- Check Play Store crash rate (last 7 days, threshold <1%)
- Check pending rollout fractions (Android staged, iOS phased)
- Run typecheck + lint + unit tests on the touched flow
- Verify backend migrations applied (dev vs prod parity)
- Sentry: top 3 unresolved issues in last 24h
- Refresh QA test accounts between sessions

**Primary observe scripts:** `play-store.sh`, `sentry.sh`, `app-store.sh`, `supabase.sh`

**Red-band auto-task triggers:**
- Play Store crash rate >1% → rollback task, halt staged rollout
- 1–2★ review spike (>2 in 24h) → triage task
- Install drop >30% week-over-week → onboarding-funnel audit

---

## 4. ERP / Daily Ops

**Signals:** daily transactional data entry, POS / inventory / P&L, multi-tenant, often field-staff users on mobile.

**Starter tasks:**
- Verify daily ops report is being generated
- Audit data integrity (no orphan rows, no negative inventory, no future-dated entries)
- Check OTP delivery rate (Twilio / MSG91 / etc.)
- Refresh dashboard KPIs (revenue, covers / units, cost %)
- Verify outbound email deliverability (SPF/DKIM/DMARC pass, Resend bounce rate)
- Backup verification: confirm last successful database backup

**Primary observe scripts:** `twilio.sh`, `resend.sh`, `supabase.sh`, `ga4.sh`, `clarity.sh`

**Red-band auto-task triggers:**
- OTP delivery <90% → SMS-provider task
- Daily-active-outlets drop >20% WoW → outreach task
- Backup failure → P0 reliability task
- Resend bounce >2% → list-hygiene task

---

## 5. AI Agent System (Daemon / Event-Bus)

**Signals:** long-running daemons, event bus (LISTEN/NOTIFY, Redis, RabbitMQ, NATS), LLM / model calls, eval harness, often Telegram-native UI.

**Starter tasks:**
- Verify all containers up (`docker compose ps`)
- Watchdog health: any auto-restart in last 24h?
- Event-bus backlog: confirm no stuck events
- Model cost tracker: tokens consumed last 24h vs budget
- Eval harness: latest accuracy score, regression vs baseline
- Telegram / Slack bot heartbeat: last user-facing message timestamp

**Primary observe scripts:** `docker.sh`, `watchdog.sh`, `postgres.sh`, `llm-cost.sh`, `eval.sh`

**Red-band auto-task triggers:**
- Container down >5 min → P0 reliability task
- Watchdog restart >0/24h → root-cause task
- LLM token spend >2× rolling 7-day average → caching / model-downgrade task
- Eval accuracy drop >5 percentage points → rollback model task

---

## 6. Job-seeker / Candidate SaaS

**Signals:** candidate-facing, resume parsing, application throughput, recruiter dashboards, often a worker pipeline behind the user-facing app.

**Starter tasks:**
- Daily signups + activation funnel
- Resume parser error rate (last 24h)
- Application submission success rate
- Recruiter outreach pipeline (warm / cold / replied)
- Billing health (failed charges, churned subscriptions)
- SEO: jobseeker-intent keyword rankings

**Primary observe scripts:** `ga4.sh`, `gsc.sh`, `sentry.sh`, `supabase.sh`, `stripe.sh`

**Red-band auto-task triggers:**
- Resume-parse success <95% → parser fix task
- Signup drop >30% WoW → funnel audit
- Failed charges >5% → billing task

---

## 7. Custom (catch-all)

If no profile fits cleanly, the agent picks **3 starter tasks** from a generic checklist:

- Health endpoint OK (define one if missing)
- Tests green on `dev`
- No critical Sentry issue in last 24h
- No stale deps (>180 days)
- No untracked / uncommitted changes outside expected locations
- No failing CI on `dev`

**Primary observe scripts:** whichever apply. Start with `sentry.sh` and a custom `health.sh`.

---

## Mixing profiles

A project can match more than one. Examples:

- **niptao.app** is *Mobile App* (primary) + *B2B SaaS* (secondary, for the web admin surface).
- **placementpilot.ai** is *B2B SaaS* (primary).
- **jinxapply.com** is *Job-seeker SaaS* (primary) + *AI Agent System* (secondary, for the Celery worker pipeline).

When a project matches more than one profile, seed starter tasks from both. The agent will prune duplicates and re-prioritize on the first Monday cadence.

## Adding a new profile

Open a PR adding a new section to this file following the format above:

- A one-line "what kind of project this is"
- Concrete "signals" — what you'd see in `package.json`, `requirements.txt`, `Dockerfile`, repo layout
- 4–8 starter tasks, concrete and verifiable
- Primary observe scripts (existing or new)
- 3–5 red-band auto-task triggers with thresholds

A good profile is **observable** (signals can be checked without asking the operator) and **actionable** (starter tasks are concrete, not "improve the codebase").
