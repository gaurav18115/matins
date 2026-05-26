# 0001 — name: matins

Date: 2026-05-26
Status: Accepted

## Context

The framework was developed internally under the name "Continuity Framework" (v0.1 → v0.4.1) across ~2 months of private use on 6 production projects. Before public release we audited the name and found:

- `continuity` as a top-level name is taken on npm and PyPI by unrelated projects.
- `agent-continuity` is already used by 3+ GitHub repositories solving adjacent problems (cross-session memory for coding agents). The most-starred (`adeluise/agent-continuity`, 3★) is described as "Lightweight skills + three markdown files for solving cross-session context" — directly overlapping marketing.
- Search-engine results for "continuity" are dominated by Apple's Continuity protocol (15k+ ★ across reverse-engineering and diagnostic tools), containerd's `continuity` metadata library, and a Minecraft mod.

Publishing under "Continuity" or any "*-continuity" variant would result in:

1. Low SEO discoverability (our project would appear below existing repos for the same query).
2. Brand confusion with `adeluise/agent-continuity` and `richardwhiteii/agent-continuity`.
3. Inability to claim npm/PyPI top-level names.

## Decision

The framework is published as **matins**.

- **Pronunciation:** MAT-ins.
- **Meaning:** the first canonical hour of prayer in the Liturgy of the Hours, said at daybreak. Carries connotations of daily devotional rhythm, watchfulness, and ancient steady practice — semantically aligned with an agent that runs every cycle, every day, without stopping.
- **Filename in user projects:** `MATINS.md` (drop-in state file at repo root).
- **Trigger phrase:** `/loop run matins`.

## Considered alternatives

| Name | Why rejected |
|---|---|
| `continuity`, `continuity-md`, `continuity-framework`, `continuity-agent` | SEO collision with Apple Continuity ecosystem + existing `agent-continuity` repos. |
| `loopfile`, `pacefile`, `tickfile`, `cyclefile`, `heartmd`, `agentbeat` | All clean on registries but felt utility-named — "no soul" per the operator. |
| `vigil`, `hearth`, `ember`, `cairn`, `loom`, `lantern`, `helm`, `kindle` | All taken on npm + PyPI; high GitHub-repo collision (20k+, 4k+, 34k+ repos respectively). |
| `compline`, `lauds`, `dayspring`, `watchnight` | All clean and on-theme but less recognizable than matins. `compline` is the matched closing-of-day pair; we reserve it for a future component (likely the shutdown / quarterly-prune ceremony) rather than the framework name. |
| `nightoffice` | Two-word compound, pun risk (religious "office" vs workplace "office") could dilute the brand register. |
| `hearthkeeper`, `keepvigil`, `tendfire`, `quietember`, `slowfire` | All clean but compound names that traded soul for first-glance accessibility. Matins keeps the depth; the README tagline ("the night office for your repo, a continuity framework for autonomous agents") carries the bridge.

## Consequences

- All references to "Continuity Framework" in user projects migrate to "matins" / "MATINS.md".
- The README positions the project as "a continuity framework for your agent" — preserving the category language for discoverability while letting the brand carry its own weight.
- `compline` is reserved as a potential future name for the quarterly-prune or graceful-shutdown component, since the matins/compline pair (first prayer of day / last prayer of day) maps naturally onto start-of-cycle / end-of-cycle ceremonies.
