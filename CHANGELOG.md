# Changelog

All notable changes to Matins are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned for v1.0
- `npx matins init` scaffolder CLI — drops `MATINS.md` + `.continuity/` skeleton into any repo
- `matins lint MATINS.md` validator — JSON Schema + structural checks
- Adapters for agent runtimes beyond Claude Code (Cursor, generic LLM tool loop)
- 3+ filled-in mature examples in `examples/`
- Docs site (Vitepress or similar)

## [0.1.0] — 2026-05-26

First public release. Framework spec, drop-in template, observe-script templates, one filled-in example.

### Added
- `README.md` — hero, tagline, quickstart, comparison table
- `templates/MATINS.md` — drop-in state-file template
- `docs/PROTOCOL.md` — the loop, decision cascade, task status values, format reference
- `docs/DOMAINS.md` — 7 starter domain profiles (B2B SaaS, Marketing, Mobile, ERP, AI Agent, Job-seeker, Custom)
- `docs/ANALYTICS.md` — the analytics feedback loop spec, threshold YAML, auto-task suggestion format
- `docs/ARCHITECTURE.md` — single-worker harness diagram + multi-project operator architecture
- `templates/observe/` — reference shell scripts for Sentry, GA4, Search Console, Vercel, Supabase, Stripe + `synth.sh`
- `examples/mature-saas/` — filled-in MATINS.md showing a project after ~30 days of cycles
- `SECURITY.md` — blast-radius docs, recommended guardrails for the auto-commit/auto-push agent surface
- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, GitHub issue/PR templates, CI workflow

### Origin
Matins is the public release of an internal framework that ran for ~2 months on 6 production projects at [Mindweave Technologies](https://mindweave.tech) — niptao.app, placementpilot.ai, jinxapply.com, restaurantdaily.ai, prahar-ai, mindweave.tech. Prior internal versions were called "Continuity Framework" (v0.1 → v0.4.1); renamed at first public release to avoid SEO collision with several prior `agent-continuity` repositories.
