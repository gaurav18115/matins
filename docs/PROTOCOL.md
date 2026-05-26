# The Matins Protocol

This document defines exactly what one `/loop` tick does, in what order, with what guarantees. The drop-in `MATINS.md` template refers back here — keep this document the canonical source.

## Prime Directive

**Never prompt the user. Never ask questions. Never wait.**

- If you need info: read `MATINS.md`, read the codebase, read git history, check the observe scripts.
- If still stuck: mark the task `BLOCKED` with a concrete unblock action, append it to `## Blockers`, ping the operator on Telegram (or your configured notify channel), and move to the next task.

The agent is the operator's deputy through the night. A deputy that wakes the operator for every decision is a worse deputy than one that makes a good-enough choice and logs why.

## The Loop (step-by-step)

```
1. Read MATINS.md.
2. Run the red-band signal pull (every cycle, fast).
   bash .continuity/observe/sentry.sh
   bash .continuity/observe/uptime.sh
   bash .continuity/observe/<critical>.sh
3. Synthesize: did any red-band threshold breach? If yes,
   write the auto-task into ## Active Tasks at the top.
4. Pick the highest-priority TODO or IN_PROGRESS task.
   Prefer items in ## This Week.
5. Check Lessons + Standing Decisions + Decisions Log.
   The agent may have answered this question before.
6. Confirm the tools to execute the task exist.
   If not → BLOCKED with a concrete unblock action.
7. Set Status = IN_PROGRESS, bump Last Verified, save MATINS.md.
8. Execute. Run tests. Verify before claiming done.
9. Update MATINS.md:
     - Status = DONE or BLOCKED (or stay IN_PROGRESS on recoverable failure)
     - Fill Outcome
     - Bump Last Verified
     - Set Next Check
10. If a lesson emerged, append to ## Lessons with a "Promoted to:" target.
11. Commit + push to dev (or current feature branch).
    Conventional commit message.
12. On milestone (ship, deploy, blocker that needs human): notify.
13. Append a ## History entry. Update ## Last Run.
14. Pick the next task. Repeat.
```

## Decision Cascade

When the agent has to make a choice:

1. **Check `## Lessons`** — a previous cycle may have learned this.
2. **Check `## Standing Decisions` and `## Decisions Log`** — there may be an ADR.
3. **Check `docs/decisions/` ADR files** — load-bearing decisions live in their own files.
4. **If none of the above answer it**: pick the simplest approach, execute, log a Lesson, and open a draft ADR if the choice is load-bearing.

The order matters. Lessons are cheap to write, ADRs are expensive — the cascade goes lightest to heaviest.

## Task Status Values

| Status | Meaning |
|---|---|
| `TODO` | Not started. |
| `IN_PROGRESS` | Actively working on it. Must have `Last Verified` from this cycle. |
| `BLOCKED` | Cannot proceed. Reason in `Outcome`, mirror in `## Blockers` with a concrete unblock action. |
| `DONE` | Complete. Result and evidence in `Outcome`. |
| `SKIPPED` | Deliberately not doing this. Reason in `Outcome`. |

## Cadence Checks

The agent runs additional work on certain cycles so the system catches its own drift.

| Cycle | Extra work |
|---|---|
| **Every cycle** | Bump `## Last Run`. Update `Last Verified` on every task touched. Commit + push if any non-state file changed. Run **red-band signal pull** (Sentry, uptime, crash rate). |
| **Every 6 cycles (~hourly if `/loop` is fast)** | Full signal pull: `bash .continuity/observe/*.sh && bash .continuity/synth.sh`. Synth's auto-task suggestions go into `## Active Tasks`. |
| **Monday morning** | Rewrite `## This Week` (cap 3). Run staleness check: any task with `Last Verified` >14 days old → flag in `## Blockers` with a "why didn't it move" note. |
| **Friday afternoon** | Append a `## Retro Log` entry: (1) what shipped? (2) what slipped, and is the blocker still real? (3) any lesson worth promoting to a rule (skill / hook / ADR)? Send a retro summary to the operator. |
| **Quarterly** (first cycle of Jan/Apr/Jul/Oct) | Prune: move entries >90 days into `archive/MATINS-YYYY-QN.md`. Delete lessons that never got promoted. Confirm `MATINS.md` is ≤200 lines. |

## Format Reference

### Task block

```
- **Task:** <concrete, measurable action>
- **Venture:** <project name>
- **Owner:** agent | human
- **Deadline:** <YYYY-MM-DD or "Daily" or "None">
- **Status:** TODO | IN_PROGRESS | BLOCKED | DONE | SKIPPED
- **Tracker:** <GH#42 | JIRA-NN | none>
- **Last Verified:** <YYYY-MM-DD — bumped on every touch>
- **Next Check:** <YYYY-MM-DD — explicit "look at this again on" date>
- **Success Criteria:** <how to know this is done>
- **Outcome:** <filled when DONE or BLOCKED>
```

### Blocker block

```
- **Item:** <what's blocked>
- **Since:** <YYYY-MM-DD>
- **Why:** <real reason — not "TBD">
- **Unblock:** <concrete action that would clear it>
- **Owner of unblock:** <agent | human-name | external-vendor>
```

### Lesson block

```
- **Lesson:** <what was learned>
- **Date:** <YYYY-MM-DD>
- **Context:** <what happened>
- **Promoted to:** <skills/<name>.md | hooks/<name> | CLAUDE.md rule | docs/decisions/NNNN | "pending">
- **Action:** <what to do differently>
```

Lessons without a "Promoted to:" destination are pruned at the quarterly review. The framework treats undestined lessons as noise — if a learning is real, it earns a place in a rule.

### ADR block (`docs/decisions/NNNN-slug.md`)

```markdown
# NNNN — <slug>
Date: YYYY-MM-DD
Status: Proposed | Accepted | Superseded by NNNN | Deprecated
Context: <what forced this decision>
Decision: <what was decided>
Consequences: <what this commits us to>
Reverses: <prior ADR number, if any>
```

ADRs are append-only. Never edit a decision in place — supersede it with a new ADR and update the prior one's `Status` to `Superseded by NNNN`.

### Retro entry

```
### <YYYY-Www> retro (<YYYY-MM-DD>)
- **Shipped:** <bullets — verifiable outputs>
- **Slipped:** <bullets, with current blocker reality-check>
- **Promote:** <lessons that became rules this week, or "none">
- **Numbers moved:** <what metrics moved, by how much — pulled from .continuity/observations.jsonl>
```

### Last Run

```
**Timestamp:** <ISO 8601>
**Cycle ID:** <YYYY-MM-DD-HHMM>
**Duration:** <minutes>
**Mode:** Scheduled | Manual
**Tasks Attempted:** <count>
**Tasks Completed:** <count>
**Tasks Failed:** <count>

### Actions Taken
1. [DONE] <what was done>
2. [FAILED] <why it failed>

### Blockers
- <what's blocked and why>

### New Lessons
- <insights from this cycle, each with a destination>

### Notes for Next Run
- <what the next cycle should know>
```

### History entry

```
### <YYYY-MM-DD> (Cycle <ID>)
- **Cycle:** <cycle-id>
- **Duration:** <minutes>
- **Result:** <completed>/<attempted> tasks completed
- **Actions:** <summary>
- **Lesson:** <key insight or "None">
```

## Canonical `/loop` Prompt

When starting the worker in a new terminal, the operator types:

```
/loop run matins
```

The agent reads `MATINS.md` in the current directory, follows this protocol, and runs continuously.

If the agent has never run in this directory before, the first tick executes the `## Bootstrap Instructions` block at the top of `MATINS.md`: classifies the project against a [Domain Profile](DOMAINS.md), seeds `## Active Tasks`, fills `## This Week`, removes the bootstrap block. From the second tick on, the file is pure state.

### Self-pacing

`/loop run matins` runs without a fixed interval — the agent self-paces. One task per tick. If no `TODO` items are ready, sleep 60–300 seconds (allowing CI / deploy / external state to settle) and re-read. Use the runtime's wakeup mechanism if available; otherwise a short `sleep` loop.

### Shutdown

`/loop stop` or Ctrl+C. The agent:

1. Finishes the current task (no half-shipped state).
2. Commits + pushes whatever's done.
3. Updates `## Last Run` with `Mode: Manual, Result: stopped by operator`.
4. Exits cleanly.

## Invariants

A correctly-running matins agent maintains these invariants. CI lint (`matins lint MATINS.md`, v1.0) will check them.

- Every task has all 10 required fields. No empty `Owner`. No empty `Success Criteria`.
- Every `BLOCKED` task has a mirrored entry in `## Blockers` with a concrete `Unblock` action.
- Every `Lesson` has a `Promoted to:` destination (use `"pending"` if not yet assigned).
- `## This Week` is ≤ 3 items.
- `## Last Run` `Timestamp` is within 24 hours of `now()` (else the file is stale → agent must update or mark itself stopped).
- File is ≤ 200 lines (older content moves to `archive/`).
