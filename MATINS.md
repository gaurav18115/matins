# MATINS.md — matins (this repo, dogfooded)

> Spec: lives in this very repo at [docs/PROTOCOL.md](docs/PROTOCOL.md). The framework drives its own development.
> Never prompt. Never wait. Always commit. Pull signals before picking work.

## Identity

**Project:** matins — a continuity framework for your agent
**Domain Profile(s):** Marketing / Landing (the public README) + Custom (the framework itself)
**Live URL:** https://github.com/gaurav18115/matins (repo + GH Pages docs site, planned)
**Repo:** https://github.com/gaurav18115/matins
**Stack:** Markdown + bash + Python (for synth). No compiled runtime.
**Operator:** Mindweave Technologies + community contributors
**Mission:** Be the boring, file-based, real-analytics-driven layer that any autonomous coding agent can stand on. Don't reinvent agent runtimes. Don't ship telemetry. Don't grow scope past "spec + templates."

## This Week — 2026-W21 (2026-05-25)

1. **Publish v0.1.0 to GitHub** — `tracker:none` — `since:2026-05-26` — initial public release, blocking work below
2. **`npx matins init` scaffolder CLI design** — `tracker:GH#1 (planned)` — `since:2026-05-26` — biggest v1 onboarding gap per honest review
3. **Field reports from the 6 internal projects** — `tracker:none` — `since:2026-05-26` — convert one into a public example for `examples/mature-mobile/`

## Active Tasks

- **Task:** Publish v0.1.0 to GitHub (owner: Mindweave Tech account)
- **Venture:** matins
- **Owner:** human
- **Deadline:** 2026-05-27
- **Status:** TODO
- **Tracker:** none
- **Last Verified:** 2026-05-26
- **Next Check:** 2026-05-27
- **Success Criteria:** Repo public at github.com/gaurav18115/matins, README renders on GitHub front page, CI workflow green on first push, LICENSE recognized by GH license-detection.
- **Outcome:**

- **Task:** Design `npx matins init` CLI (package layout, command surface, exit codes)
- **Venture:** matins
- **Owner:** agent
- **Deadline:** 2026-06-02
- **Status:** TODO
- **Tracker:** none (issue to be opened after v0.1.0 publish)
- **Last Verified:** 2026-05-26
- **Next Check:** 2026-05-30
- **Success Criteria:** `docs/decisions/0002-init-cli.md` ADR drafted with: language choice (Node vs Python vs Go), command surface (`init`, `lint`, `prune`), packaging (npm + brew tap), opt-out flags. Reviewer approval before any code lands.
- **Outcome:**

- **Task:** Open `examples/mature-mobile/MATINS.md` from a sanitized version of niptao's running state
- **Venture:** matins
- **Owner:** agent
- **Deadline:** 2026-06-05
- **Status:** TODO
- **Tracker:** none
- **Last Verified:** 2026-05-26
- **Next Check:** 2026-05-30
- **Success Criteria:** Anonymized MATINS.md (no Doppler keys, no real user counts, no internal Slack channels) committed to `examples/mature-mobile/`. README updated to list it.
- **Outcome:**

## Backlog

- **Task:** `matins lint MATINS.md` validator — JSON Schema + structural checks
- **Priority:** P1
- **Notes:** Listed in CHANGELOG `## [Unreleased]` v1.0 plan. Blocks community PRs that add malformed `MATINS.md` examples.

- **Task:** Adapter spec for Cursor / Codex / generic LLM tool loop
- **Priority:** P1
- **Notes:** Currently the protocol is implicitly Claude-Code-shaped. Decouple the spec from the runtime.

- **Task:** GH Pages docs site (Vitepress or Mintlify)
- **Priority:** P2
- **Notes:** Optional v1.x. README + docs/ are sufficient until traffic justifies a docs site.

- **Task:** Reach out to claude-mem, agent-continuity (adeluise), tricore maintainers for cross-link discussions
- **Priority:** P2
- **Notes:** OSS in this space is small. Mutual citations help everyone.

- **Task:** Submit to awesome-claude-code, awesome-llm-agents, awesome-ai-agents
- **Priority:** P3
- **Notes:** After v0.1.0 has been live for ~2 weeks with at least one external star.

## Blockers

*(none — pre-publish)*

## Decisions Log

- [0001 — name: matins](docs/decisions/0001-name-matins.md) — Accepted 2026-05-26

## Decisions & Constraints

### Standing Decisions
- Default branch for agent work: `main` (this is a docs-only repo until a CLI exists; no `dev` branch needed yet).
- Conventional commits required.
- No telemetry. Ever. The framework runs in the user's repo + their agent's process. Nothing phones home.
- No hosted SaaS component. Matins is files. If someone builds a hosted layer on top, it lives in a separate project under a different name.
- No central scheduler. Self-pacing via the agent runtime's loop mechanism only.
- Documentation changes ship in the same commit as the code change that requires them. No "I'll document it later."

### Constraints
- **Off-limits without approval:** `git push origin main` (until the repo is public and CI is green), creating npm/PyPI packages (until name + scope are confirmed), publishing GH Releases.

## Skills & Connectors

### Active Connectors (signals — post-publish)
- **GitHub stars / forks / issues / PRs** — via `gh api`, every 6 cycles
- **npm downloads** (once `matins` is published) — via npm registry API
- **Mentions** (HN, Twitter, Reddit r/ClaudeAI / r/LocalLLaMA) — TBD, may stay manual

### Available Skills
- Claude Code skill ecosystem (for the operator who writes this repo)

## Last Run

**Timestamp:** 2026-05-26T16:48:00Z
**Cycle ID:** 2026-05-26-1648
**Duration:** N/A — this is the file's initial commit, written by hand-via-agent during the v0.1.0 prep session
**Mode:** Manual (bootstrap)
**Tasks Attempted:** 0
**Tasks Completed:** 0
**Tasks Failed:** 0

### Actions Taken
- Initial bootstrap. This repo doesn't have a running matins agent yet — it will start one once the repo is published and the operator can `/loop run matins` against it.

### Blockers
- None.

### New Lessons
- None.

### Notes for Next Run
- The first real `/loop` tick should pull GH signals (stars, issues opened, PRs opened) and replace this `Last Run` block with a real entry.

## Lessons

- **Lesson:** OSS naming research must happen before any v1 publish. Three prior `agent-continuity` repos in our exact space would have buried us in search if we had shipped under that name.
- **Date:** 2026-05-26
- **Context:** Pre-publish audit found `adeluise/agent-continuity`, `richardwhiteii/agent-continuity`, and several others. Name pivoted to `matins`.
- **Promoted to:** [docs/decisions/0001-name-matins.md](docs/decisions/0001-name-matins.md)
- **Action:** None going forward — the name is set.

- **Lesson:** A single 547-line spec file mixes too many audiences. Drop-in template, protocol reference, domain profiles, and analytics doc should be separate files even if the total page count grows.
- **Date:** 2026-05-26
- **Context:** Pre-publish review flagged the monolithic `continuity-framework.md` as a 60% complete v1. Split into `templates/MATINS.md` (~120 lines), `docs/PROTOCOL.md`, `docs/DOMAINS.md`, `docs/ANALYTICS.md`, `docs/ARCHITECTURE.md`.
- **Promoted to:** repo file structure + CONTRIBUTING note about file-scope discipline.
- **Action:** Future v2 evolutions stay in their dedicated docs. No re-monolithing.

## Retro Log

*No retros yet — first one will be Friday 2026-05-29.*

## History

### 2026-05-26 (Cycle 2026-05-26-1648)
- **Cycle:** 2026-05-26-1648 (bootstrap)
- **Duration:** ~2 hours (initial v0.1.0 prep session)
- **Result:** v0.1.0 ready for publish: README, LICENSE, CHANGELOG, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT, SHOWCASE; docs/{PROTOCOL,DOMAINS,ANALYTICS,ARCHITECTURE,decisions/0001-name-matins}.md; templates/{MATINS.md,observe/{sentry,ga4,gsc,vercel,supabase,stripe,synth}.sh,observe/thresholds.example.yaml,observe/README.md}; examples/mature-saas/MATINS.md; .github/{ISSUE_TEMPLATE/{bug,feature,domain-profile,field-report}.yml, PULL_REQUEST_TEMPLATE.md, workflows/ci.yml}; this MATINS.md.
- **Actions:** Name research (npm/PyPI/GH), framework split from 547 lines into 7 files, ADR for the name, observe-script reference impls, one filled-in mature example.
- **Lesson:** Both lessons above.
