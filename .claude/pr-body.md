# Guide: dependabot auto-merge + Claude Code PR settings (all 4 frameworks)

Adds two self-operating improvements to the guide's setup flow — Dependabot patch updates now merge themselves once CI passes, and Claude Code can open and auto-fix its own PRs — both documented across all four framework copies in one pass.

## What changed

- **Step 2.6** (all 4 frameworks): Documents the Claude Code **Automatically create PR** and **Auto-fix PR** settings so readers enable them at first connect — Claude then opens and monitors PRs without a second prompt.
- **Step 8.2** (all 4 frameworks): Extended to include an "Allow auto-merge" click in GitHub Settings → General and a paste prompt that creates `.github/workflows/dependabot-auto-merge.yml`; patch-level Dependabot PRs now self-merge once CI is green.
- **Step 9.7** (all 4 frameworks): Adds Dependabot to the ruleset bypass list (Integration · Pull requests only) so the auto-merge workflow can skip the approval gate — CI still runs and must pass.
- **Step 9 Note** (all 4 frameworks): Adds a sentence clarifying that the bypass waives only the approval requirement, not CI.
- **Step 12.1 audit prompt** (all 4 frameworks): Adds `dependabot-auto-merge.yml` to the manifest the audit prompt checks.
- **Step 12.4** (all 4 frameworks): Updates "two clicks" → "three clicks" to reflect the new Allow auto-merge click added at step 8.2.
- **`.claude/review/`**: Three reviewer verdicts written for this PR (security ✅, scale ✅, code ✅).

## Gate

- [x] Goal restated; only what the task needs was touched.
- [x] Every platform claim verified against current official docs and stamped; none left older than ~6 months unchecked.
- [x] Shared content moved across ALL framework copies; each changed pipe's dependents moved with it; anchors / steps / headings still parallel.
- [x] The three reviewers ran; `.claude/review/` verdicts refreshed this PR.
- [x] Memory updated at the narrowest tier and pruned.
- [x] One PR, with a plain-English "what changed / how to undo" for the human.

## For you
**What changed:** All four framework copies of `docs/<fw>/02-set-it-up.md` now teach readers to enable Claude Code's auto-PR/auto-fix settings (step 2.6) and to paste the Dependabot auto-merge workflow (step 8.2), with the matching ruleset bypass (step 9.7) and audit manifest entry (step 12.1) updated to match.
**What you do next:** Review the diff, then merge into `main` — no manual dashboard steps needed for the guide repo itself.
**How to roll it back:** Revert this PR; the four `02-set-it-up.md` files return to their pre-PR state and the `.claude/review/` files are removed.
