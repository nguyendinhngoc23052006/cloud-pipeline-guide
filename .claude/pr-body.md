# Clarify step 6.7: previews get the same prefix names as production (Vite/Astro/SvelteKit)

Step 6.7 changes the Supabase→Vercel integration prefix so previews receive env vars under the
framework-native prefix (e.g. `VITE_`). Previously the step said only `→ **Save**`, leaving
readers to wonder why step 6.2 set production vars by hand if the integration handles injection.
The parenthetical clarifies: after step 6.7, previews receive the same prefix names set at step
6.2; production was already using them because step 6.2 set them manually.

## What changed

- **`docs/vite/02-set-it-up.md` step 6.7**: appended `(previews now receive the same \`VITE_\`
  names you set in step 6.2 — production was already using them)` to the `→ **Save**` line.
- **`docs/astro/02-set-it-up.md` step 6.7**: same parenthetical with `PUBLIC_`.
- **`docs/sveltekit/02-set-it-up.md` step 6.7**: same parenthetical with `PUBLIC_`.
- **`docs/next/02-set-it-up.md`**: unchanged — Next.js has no step 6.7 prefix-change step
  (its default `NEXT_PUBLIC_` prefix is already correct).
- **`.claude/review/`**: three reviewer verdicts refreshed for this PR.

## Self-check

- [x] base = main; exactly one PR
- [x] ≤ 1 migration, UTC-timestamped latest; new tables have RLS; src/types matches
- [x] tests/lint/typecheck/e2e green; happy AND unhappy paths exercised
- [x] scripts still named exactly `lint`, `typecheck`, `test`, and `e2e`
- [x] key read from `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY ?? VITE_SUPABASE_ANON_KEY`; `envPrefix: ['VITE_']`; nothing hardcoded; no secret in code
- [x] irreversible actions guarded + idempotent + flagged
- [x] no avoidable debt; memory updated and pruned — no new lesson; parenthetical is prose only
- [x] migrations explained in plain English
- [x] reviewers ran — `.claude/review/*` verdicts refreshed this PR
- [x] every subagent dispatched on a model below the orchestrator's — never inherited

## For you
**What changed:** Step 6.7's `→ **Save**` line in Vite, Astro, and SvelteKit now ends with a parenthetical explaining that after saving, previews receive the same prefix-named vars as production (which was already set up at step 6.2).
**What you do next:** Review the diff, then merge into `main`. No dashboard action required.
**How to roll it back:** Revert this PR; the three `02-set-it-up.md` files return to their pre-PR state (the `→ **Save**.` without the parenthetical).
