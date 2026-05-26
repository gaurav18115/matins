# Examples

What `MATINS.md` looks like in real projects, at different stages.

## Available examples

- **[mature-saas/](mature-saas/MATINS.md)** — RouteAtlas, a B2B SaaS after ~30 days of cycles. Bootstrap block long gone. Real-feeling but fictitious — names, metrics, and ADR numbers are illustrative.

## Planned examples (PRs welcome — see [CONTRIBUTING.md](../CONTRIBUTING.md))

- `mature-mobile/` — a React Native / Expo app after ~30 days
- `mature-landing/` — a marketing site after ~30 days
- `day-zero/` — what `MATINS.md` looks like the day you drop the template in, before the first `/loop` tick
- `post-incident/` — `MATINS.md` after a major production incident, showing the ADR + lesson + retro chain

## Reading the examples

The examples are written to be **read top to bottom in 5 minutes**. They should give you a feel for:

- How the agent uses `## This Week` (≤3 items, rewritten each Monday)
- How `## Active Tasks` looks during ongoing work vs after completion
- How auto-synth tasks integrate alongside human-authored tasks (look for `Tracker: auto-synth-*`)
- How `## Blockers` is used (always with a concrete unblock action)
- How `## Decisions Log` accumulates as ADRs over time
- How `## Lessons` get a `Promoted to:` destination (no orphan lessons)
- How `## Retro Log` ties Friday retrospectives to the week's metric movements
- How `## History` grows as a searchable audit trail

If you've been running matins on a real project and want to contribute an anonymized example, please do — these are the single best onboarding asset for new users.
