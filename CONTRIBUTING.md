# Contributing to Matins

Thank you for considering a contribution. This project is pre-1.0 — feedback on the spec, documentation, and reference templates is especially valuable right now.

## What's most useful

In rough priority order:

1. **Run matins on a real project and report back.** What worked, what didn't, what the agent kept getting wrong. Open a discussion or an issue tagged `field-report`.
2. **New domain profiles.** If you run matins on a project type not covered in [docs/DOMAINS.md](docs/DOMAINS.md) (game engine, scientific compute, embedded firmware, …), open a PR adding the profile + its starter tasks.
3. **New observe scripts.** Templates in `templates/observe/` for signal sources we don't cover (Datadog, Honeycomb, PostHog, Mixpanel, Crashlytics, App Store Connect, …). One script per source, with a comment block explaining required env vars.
4. **Filled-in examples.** A `MATINS.md` from a project that's been running matins for 30+ days — anonymized — into `examples/`. These are the single best onboarding asset.
5. **Adapter integrations.** Matins assumes a Claude-Code-style `/loop` invocation. Adapters for Cursor, Codex, Continue, Aider, and generic LLM tool loops are all welcome.
6. **Bug fixes** to the templates and observe scripts.
7. **Doc improvements** — typos, clarity, missing examples.

## What is out of scope

- **Re-architecting around a non-markdown state format.** A YAML, JSON, or database-backed state file is a different project. Matins is intentionally markdown.
- **Adding a hosted / SaaS component.** Matins runs locally, in your agent's working directory. There is no cloud component and we are not planning one.
- **Removing the analytics feedback loop.** The loop is the differentiator, not an optional add-on.

If you have a strong case for any of these, open a discussion first — but be prepared for a "no, but here's an adjacent thing that could work."

## Workflow

1. **Open an issue first** for anything beyond a typo. Saves you wasted work on a PR direction we won't accept.
2. **Fork + branch.** Branch name should be `<type>/<short-slug>` — `feat/posthog-observe`, `fix/threshold-yaml-parse`, `docs/quickstart-cursor`.
3. **Keep PRs small.** One concern per PR. We'd rather review three small ones than one large one.
4. **Update the CHANGELOG.** Add a bullet under `## [Unreleased]`.
5. **Run the linter** (once `matins lint` exists in v1.0). For now: confirm any `MATINS.md` you add validates against the structure in `templates/MATINS.md`.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
feat(domains): add embedded-firmware domain profile
fix(observe): correct GSC sitemap pull when site has multiple verifications
docs(security): clarify level-3 autonomy warning
```

## Code of Conduct

Be kind. Assume good faith. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) (Contributor Covenant v2.1).

## Maintainers

Currently a single maintainer (@gaurav18115 / Mindweave Technologies). Response time goal: 72 hours for issues, 1 week for PRs. If you don't hear back in that window, feel free to ping with a comment.

## License

By contributing, you agree your contributions are licensed under [MIT](LICENSE).
