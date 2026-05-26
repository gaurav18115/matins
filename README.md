# Matins

> **A continuity framework for your agent.**
> One markdown file. The agent reads it, picks the next task, executes, updates, commits, pings, loops. Forever.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status: pre-1.0](https://img.shields.io/badge/status-pre--1.0-orange)](#status)
[![Made for: Claude Code](https://img.shields.io/badge/made_for-Claude_Code-purple)](https://docs.claude.com/en/docs/claude-code)

---

## What

Matins is the **night office for your repo** — a single drop-in `MATINS.md` file that any agent can read to know exactly what to do next, every cycle, without you in the loop.

```
You sleep. The agent runs matins. Each tick reads the file, picks a task,
ships work, updates the file, commits, pushes, pings you on milestones.

You wake up to a `## History` of overnight cycles, a `## Retro Log` of what
moved, and a project that has been quietly tended through the night.
```

Named for the first canonical hour of prayer — said at daybreak, every day, for a thousand years. The agent has a matins of its own.

## Why this exists

Most "autonomous agent" projects solve the **cold-resume problem** — your agent forgets between sessions, so they save state at the end and restore it at the start.

That's the wrong problem. Cold-resume just means the agent stops less often. **The right problem is: the agent never stops.**

Matins is built around five claims:

1. **State belongs in a markdown file in the repo, not a vector DB.** Diffable. Reviewable. Version-controlled. Portable across agent runtimes.
2. **The agent should self-pace, not be scheduled.** It picks its own next task based on what's stale, what's red, what just shipped.
3. **Every cycle must produce a unit of work.** Not just a status update. The agent commits + pushes + verifies + pings.
4. **Real-world analytics drive task creation.** The agent watches Sentry, GA4, Search Console, Stripe, Vercel cost. Red signals → new tasks. Improved metrics → close old tasks. See [docs/ANALYTICS.md](docs/ANALYTICS.md).
5. **Decisions accrue. Lessons compound.** A `MATINS.md` that's been running for 6 months is denser than any onboarding doc you could write — because the agent has been living the project the whole time.

## The differentiator: Analytics Feedback Loop

This is the part most agent-state frameworks don't have, and it's the reason Matins agents don't drift.

```
Real-world signals  →  ingest  →  synthesize vs thresholds  →  create / close / re-prioritize tasks
        ↑                                                                       │
        │                                                                       ▼
        └────────────  agent ships work to production  ←──────  agent executes
```

Every cycle, the agent runs `.continuity/observe/*.sh` (Sentry, GA4, GSC, Vercel, Stripe, …), diffs against the previous reading, and either creates new tasks (red-band signals) or closes stale tasks (metrics improved). Friday retros ask: *did we move a number, or just ship code?*

Full spec → [docs/ANALYTICS.md](docs/ANALYTICS.md).

## Quickstart

```bash
# 1. Install the CLI (one-time)
curl -fsSL https://raw.githubusercontent.com/gaurav18115/matins/main/bin/matins \
  -o /usr/local/bin/matins && chmod +x /usr/local/bin/matins

# 2. In any project directory:
matins init                  # drops MATINS.md + .continuity/ skeleton + gitignore rule
matins lint                  # confirm the file is well-formed

# 3. In Claude Code (or your favorite agent runtime — see docs/ADAPTERS.md), type:
/loop run matins
```

The first cycle reads `MATINS.md`, classifies your project against a [Domain Profile](docs/DOMAINS.md), seeds `## Active Tasks` from your current state + initial signal pull, and starts working.

> Don't want to install? Run one-off:
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/gaurav18115/matins/main/bin/matins) init
> ```

> `npx matins init` (proper Node package) is on the v1.0 roadmap. The current shell CLI ships with v0.2.0.

## How matins differs from other agent-state projects

| | matins | agent-continuity ([1][a1], [2][a2]) | tricore | LangGraph |
|---|:-:|:-:|:-:|:-:|
| Single markdown as state | ✅ | △ 3 files | ❌ 3-layer | ❌ code |
| Self-bootstrapping (one-liner trigger) | ✅ | ❌ | ❌ | ❌ |
| **Forever-loop autonomy** | ✅ | ❌ | ❌ | ✅ via code |
| **Analytics feedback loop** | ✅ | ❌ | ❌ | ❌ |
| Domain profiles built in | ✅ 7 | ❌ | ❌ | ❌ |
| Cadence checks (daily/weekly/quarterly) | ✅ | ❌ | ❌ | ❌ |
| Per-cycle git commit + push | ✅ | ❌ | ❌ | △ |
| ADR + Lessons + Retro structure | ✅ | △ | ✅ | ❌ |

[a1]: https://github.com/adeluise/agent-continuity
[a2]: https://github.com/richardwhiteii/agent-continuity

## What you get when you adopt matins

- **`MATINS.md`** — the single state file. Identity, This Week (≤3), Active Tasks, Backlog, Blockers, Decisions Log, Lessons, Retro Log, History, Last Run. See [templates/MATINS.md](templates/MATINS.md).
- **The Protocol** — what one `/loop` tick does, exactly. Picks a task, checks Lessons + ADRs, executes, updates, commits, pushes, pings. See [docs/PROTOCOL.md](docs/PROTOCOL.md).
- **Domain Profiles** — 7 starter task catalogs for B2B SaaS, Marketing Site, Mobile App, ERP/Daily Ops, AI Agent System, Job-seeker SaaS, Custom. See [docs/DOMAINS.md](docs/DOMAINS.md).
- **Analytics Feedback Loop** — the script skeletons + threshold YAML that turn real-world signals into auto-generated tasks. See [docs/ANALYTICS.md](docs/ANALYTICS.md).
- **Reference architecture** — diagrams for the single-worker harness and the multi-project operator setup. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Status

**Pre-1.0.** Battle-tested in private on 6 production projects (B2B SaaS, two marketing sites, mobile app, ERP, AI agent system). Going public for community feedback before a v1.0 freeze.

Known gaps before v1.0:
- [x] **Shell-based init + lint CLI** — shipped in v0.2.0 (`bin/matins`).
- [ ] **`npx matins init` proper Node package** — published to npm (shell script works today, Node package for richer DX).
- [ ] **JSON Schema** for stricter `matins lint` (today's lint covers structure + Active Tasks fields).
- [x] **Filled-in mature examples** — `examples/mature-saas/` and `examples/mature-mobile/` shipped.
- [x] **Adapter spec for other runtimes** — see [docs/ADAPTERS.md](docs/ADAPTERS.md) (Cursor, Aider, Codex, Continue, custom LLM loops).

See [CHANGELOG.md](CHANGELOG.md) and the [v1.0 milestone](https://github.com/gaurav18115/matins/milestone/1).

## Security

Matins agents have write access to your repo, auto-commit + auto-push to non-protected branches, and can deploy to preview environments. **This is non-trivial trust.** Read [SECURITY.md](SECURITY.md) before pointing one at a production-adjacent project, and configure the guardrails in `## Decisions & Constraints` of your `MATINS.md`.

## Contributing

Bug reports, domain profiles, observe scripts for new signal sources, and adapter integrations are all welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

If you've been running matins on a real project, please add yours to [SHOWCASE.md](SHOWCASE.md) (PR welcome).

## License

[MIT](LICENSE) © Mindweave Technologies Pvt. Ltd. and contributors.

---

> *"And the morning office is sung in the dark, so that you may know the dark is not the end."*
