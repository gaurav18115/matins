<!-- Thanks for the PR. Keep it small and focused — one concern per PR is easier to review. -->

## What does this change

<!-- One paragraph. What's the user-visible effect? -->

## Why

<!-- What problem does it solve? Link to the issue if there is one. -->
Closes #

## Scope

- [ ] Template (`templates/MATINS.md`)
- [ ] Observe script(s) — list which: 
- [ ] Synth (`templates/observe/synth.sh`)
- [ ] Domain profile (`docs/DOMAINS.md`)
- [ ] Protocol change (`docs/PROTOCOL.md`) — **note breaking changes below**
- [ ] Architecture / analytics docs
- [ ] Examples
- [ ] CI / .github
- [ ] Other:

## Breaking changes

<!-- If you changed PROTOCOL.md, MATINS.md schema, or the observe-script contract,
     describe what existing users have to do to migrate. -->

## How was this tested

<!-- For template/observe changes: did you run it against a real project? Which one (anonymized)?
     For docs: did you re-read the surrounding section to make sure it still flows? -->

## Checklist

- [ ] CHANGELOG.md updated (under `## [Unreleased]`)
- [ ] No secrets / credentials in the diff
- [ ] Documentation reflects the change
- [ ] If observe-script changed: comments at the top describe required env vars
