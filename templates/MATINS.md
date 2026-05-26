# MATINS.md

> **A continuity framework for your agent.** Spec: <https://github.com/gaurav18115/matins>
> The agent reads this file. Do one task, update the file, commit, push, ping. Loop.
> **Never prompt. Never wait. Always commit. Pull signals before picking work.**

---

## Bootstrap Instructions

**You are the matins agent for this project. First tick:**

1. Read `README.md`, `CLAUDE.md` (or `AGENTS.md`), `CHANGELOG.md`, latest 30 commits, recent CI / observability dashboards.
2. **Classify** this project against a [Domain Profile](https://github.com/gaurav18115/matins/blob/main/docs/DOMAINS.md) — one or more profiles can apply.
3. **Bootstrap** `.continuity/`: copy starter observe scripts from `<matins-repo>/templates/observe/` into `.continuity/observe/`. Write `.continuity/thresholds.yaml`. Gitignore `.continuity/observations.jsonl`.
4. **Run the first signal pull.** `bash .continuity/observe/*.sh && bash .continuity/observe/synth.sh`. Any red-band signals become auto-tasks at the top of `## Active Tasks`.
5. **Fill in `## Identity`** with project name, live URL, repo, stack, mission.
6. **Fill `## This Week`** with ≤3 items — the most active in-flight feature (`git log --oneline -30`) intersected with signal red-bands.
7. **Fill `## Active Tasks`** from signal red-bands + open issues + TODO comments + README promises not yet implemented.
8. **Delete this Bootstrap Instructions block.** From the second tick on, this file is pure state.
9. Start executing immediately. Do not wait for a second `/loop` tick.

---

## Identity

**Project:** (name, one-line description)
**Domain Profile(s):** (one or more — see docs/DOMAINS.md)
**Live URL:** (production URL, if any)
**Repo:** (GitHub/GitLab URL)
**Stack:** (one-line tech stack)
**Operator:** (name + contact, optional)
**Mission:** (what this project is trying to achieve)

## This Week

> Hard cap: 3 items. What MUST move by Friday. Rewritten every Monday.

1.
2.
3.

## Active Tasks

- **Task:**
- **Venture:**
- **Owner:** agent
- **Deadline:**
- **Status:** TODO
- **Tracker:**
- **Last Verified:**
- **Next Check:**
- **Success Criteria:**
- **Outcome:**

## Backlog

*(lower-priority items)*

## Blockers

> Items that have stalled. Each MUST name what would unblock it and who owns the unblock.

- **Item:**
- **Since:**
- **Why:**
- **Unblock:**
- **Owner of unblock:**

## Decisions Log

> ADRs live in `docs/decisions/NNNN-slug.md`. This section is an index — never edit a decision in place; supersede it with a new ADR.

- (empty)

## Decisions & Constraints

### Standing Decisions
- **Never prompt the user for input.** If stuck, mark `BLOCKED` and move on.
- **Never push to `main`/`master`** without explicit permission. Default branch for agent work: `dev` (or a feature branch).
- **Never delete data or run destructive commands** without permission (`rm -rf`, `DROP`, `TRUNCATE`, force-push, `git reset --hard`).
- **Update this file after every action**, not just at the end of a cycle.
- **Check Lessons before starting any task.**
- **Cap this file at 200 lines.** Older content rolls to `archive/MATINS-YYYY-QN.md` on the quarterly prune.
- **Commit + push every cycle** that produced real changes. Conventional commit messages.
- **Notify the operator** on milestone transitions (task DONE that ships externally, new BLOCKED that needs human help, deploy successful, deploy failed).

### Constraints
- **Permissions:** Can read/write files, run tests, install dependencies, commit & push to non-protected branches, deploy to preview environments. Cannot deploy to production, publish to app stores, or send customer-visible communications without approval.
- **Off-limits:** Production deployments, external API calls with customer-visible side effects, deleting user data, mutating production DB, rotating secrets, modifying CI workflow files without an ADR.

## Skills & Connectors

### Active Connectors (signals)
- (filled in based on which `.continuity/observe/*.sh` scripts exist)

### Available Skills
- (filled in based on agent runtime — Claude Code skills, MCP servers, etc.)

## Last Run

*No runs yet — bootstrap pending.*

## Lessons

> Lessons are kept here only if they have a destination. Each lesson must point to where the rule now lives (a skill, a hook, a project rule, an ADR). Lessons that just sit get pruned at quarterly review.

*No lessons yet.*

## Retro Log

> Friday cycle generates an entry. Three questions, no fluff: what shipped, what slipped, what got promoted to a rule. Plus: which numbers moved (from `.continuity/observations.jsonl`).

*No retros yet.*

## History

*Empty — first run pending.*

---

## Quick reference

- **Protocol:** <https://github.com/gaurav18115/matins/blob/main/docs/PROTOCOL.md>
- **Domain profiles:** <https://github.com/gaurav18115/matins/blob/main/docs/DOMAINS.md>
- **Analytics feedback loop:** <https://github.com/gaurav18115/matins/blob/main/docs/ANALYTICS.md>
- **Architecture diagrams:** <https://github.com/gaurav18115/matins/blob/main/docs/ARCHITECTURE.md>
- **Security model:** <https://github.com/gaurav18115/matins/blob/main/SECURITY.md>
