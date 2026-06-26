Part 2 restructured from 12 platform-centric steps to 14 dependency-ordered steps. The key change: Supabase project creation (now step 3) moves before the scaffold (step 5) and Vercel import (step 7), because creating a Supabase project depends only on having a repo — not on the scaffold or Vercel. This gives readers a clearer mental model: stand up the three platforms first (steps 1–8), then build the pipeline on top of them (steps 9–14).

Step mapping: Old 1→New 1, Old 2→New 2, Old 5.1–5.5→New 3, Old 3→New 4, Old 4→New 5, Old 5.6→New 6, Old 6.1–6.4→New 7, Old 6.5–6.8→New 8, Old 7→New 9, Old 8→New 10, Old 9→New 11, Old 10→New 12, Old 11→New 13, Old 12→New 14.

All step references updated across: 02-set-it-up.md (all 4 frameworks), 01-the-model.md (all 4), 06-keeping-it-current.md (all 4), 07-decision-log.md (all 4, + new decision bullet), MEMORY.md, docs/CLAUDE.md, and root CLAUDE.md (broken anchor fixed).

## Self-check
- [x] base = main; exactly one PR
- [x] ≤ 1 migration, UTC-timestamped latest; new tables have RLS; src/types matches
- [x] tests/lint/typecheck/e2e green; happy AND unhappy paths exercised
- [x] scripts still named exactly `lint`, `typecheck`, `test`, and `e2e`
- [x] key read from `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY ?? VITE_SUPABASE_ANON_KEY`; `envPrefix: ['VITE_']`; nothing hardcoded; no secret in code
- [x] irreversible actions guarded + idempotent + flagged
- [x] no avoidable debt; memory updated and pruned
- [x] migrations explained in plain English
- [x] reviewers ran — `.claude/review/*` verdicts refreshed this PR
- [x] every subagent dispatched on a model below the orchestrator's — never inherited

## For you
**What changed:** Part 2 (02-set-it-up.md) restructured from 12 to 14 steps across all 4 framework copies — Supabase project creation now step 3 (before scaffold + Vercel), Supabase↔Vercel integration now step 8. All downstream step references updated across 01, 06, 07, MEMORY.md, docs/CLAUDE.md, root CLAUDE.md.
**What you do next:** Review the diff, check that step ordering feels correct, then merge.
**How to roll it back:** Revert this PR. No platform config was changed — this is a documentation-only restructuring.
