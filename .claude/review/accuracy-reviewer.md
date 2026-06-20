# accuracy-reviewer verdict — 2026-06-20

**Status:** PASS (independent dispatch, sonnet).

**Scope:** five additions to the constitution block in step 3 of `docs/{vite,next,astro,sveltekit}/02-set-it-up.md`. Reviewer read all 4 copies, `MEMORY.md`, and its own memory sidecar.

**Platform-claim audit:** no NEW platform claim introduced.
- Verify-before-asserting (line 80): epistemic meta-rules; no platform dependency.
- Code-floor + Effort scaling (line 81): language-agnostic code style; no platform dependency.
- `## How you communicate` (lines 85–97): output-style rules; no platform claim.
- Action care bullet (line 148): names `--no-verify`, `--force`, lockfile-delete — stable Unix-convention CLI flags, not platform-version-specific. Identical across all 4 copies.
- Skill-first bullet (line 176): names `/prototype`, `/test`, `/verify`, `/revert` — confirmed defined in the SAME file at step 10 (lines 532, 538, 544, 550 in all 4 copies). No silent rename.

**Existing-stamp staleness check:** the June-2026 framework env-wiring stamp in `MEMORY.md` is not made stale by these additions. The newly-added meta-behavior-layer line in MEMORY.md is a record-keeping note, not a platform claim requiring its own verification.

**Byte-identity check:** all 5 additions appear at identical line numbers with identical text in all 4 copies. Framework-specific deltas (Architecture & structure, Self-check fifth bullet) untouched.

**Verdict:** PASS — no flags, no Verified stamp needed, no stamp made stale.
