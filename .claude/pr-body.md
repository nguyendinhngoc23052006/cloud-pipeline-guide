# Retire prefix bridge + close/reopen workarounds; add step 6.7; warn self-hosted runners (all frameworks)

The Supabase→Vercel integration's per-connection prefix is configurable (field-verified Jun 2026;
supabase/supabase PR #28058 merged Jul 2024). Setting it to each framework's native prefix means
production and previews share the same env-var names — no cross-prefix fallback is needed.
Env sync also fires on push and branch creation, not only at PR-open (field-verified Jun 2026) —
so the "close and reopen the PR" workaround is also retired.

## What changed

- **New step 6.7** in Vite, Astro, SvelteKit `docs/<fw>/02-set-it-up.md`: sets the
  integration's per-connection prefix after step 6.5 installs the marketplace app
  (the Supabase→Vercel connection only exists from that point) — Vite → `VITE_`,
  Astro/SvelteKit → `PUBLIC_`; Next.js needs no change (default `NEXT_PUBLIC_` matches).
- **Prefix bridge retired** in Vite, Astro, SvelteKit: removed the cross-prefix fallback
  chains (`VITE_ ?? NEXT_PUBLIC_`, `PUBLIC_ ?? NEXT_PUBLIC_`) from scaffold prompts, unit
  tests, architecture lines, self-checks, memory examples, audit prompts, and
  `06-keeping-it-current.md` env-name contract sections and workaround table rows.
- **Close/reopen workaround retired** in all 4 copies: step 6 ✗ and `/verify` skill
  updated to "push any commit to the PR branch — env sync fires on push and branch
  creation as well as PR-open"; workaround table row removed.
- **`docs/<fw>/07-decision-log.md`** (all 4 copies): env-var seam bullet corrected,
  verified-pass paragraph updated with field-verified Jun 2026 stamps for both retirements.
- **`docs/<fw>/01-the-model.md`** (all 4 copies): env-contract paragraph rewritten to
  name only the framework's native prefix and note step 6.7.
- **`MEMORY.md`**: per-framework env wiring section rewritten to document step 6.7, the
  native prefix per framework, and both retirements with canonical stamps.
- **Three earlier arrow-rule fixes** (constitution block) included from the prior scope.
- **Step 8.2 "Dependabot on self-hosted runners" warning** added to all 4 copies: while
  turning Dependabot security updates ON, users must also confirm "Dependabot on
  self-hosted runners" is OFF — if it is ON with no self-hosted runners configured,
  all Dependabot jobs queue indefinitely and silently never run.
- **Step 12 audit prompt (Vite only)**: "two-prefix fallback chain" replaced with
  "single-prefix VITE_ supabaseClient" — the cross-prefix bridge was retired in this
  PR and the audit prompt was still describing the old scaffold.
- **Step 12.4 (all 4 copies)**: "three clicks" updated to "settings" with self-hosted
  runners OFF added to the parenthetical — now consistent with the expanded step 8.2.
- **Step 4 scaffold prompt `runs-on` fix (all 4 copies)**: previous text said "omit the
  runs-on field" implying `runs-on` is a valid `dependabot.yml` option — it is not;
  `runs-on` belongs to GitHub Actions workflow syntax, not the Dependabot config schema
  *(docs, Jun 2026)*. Replaced with "no runner field — Dependabot uses GitHub-hosted
  runners unless the 'Dependabot on self-hosted runners' setting is ON."
- **Step 5.1 GitHub-repo-prompt removal (all 4 copies)**: "choose your GitHub repo when
  prompted" described a wizard prompt that does not exist in the Supabase New Project flow
  *(docs, Jun 2026)*; GitHub repo connection happens separately in step 5.6. Removed the
  false instruction; added "(you won't see it again)" to the password note — the only
  irreversible action in the step.
- **`.claude/review/`**: three reviewer verdicts refreshed for this PR.

## Self-check

- [x] base = main; exactly one PR
- [x] ≤ 1 migration, UTC-timestamped latest; new tables have RLS; src/types matches
- [x] tests/lint/typecheck/e2e green; happy AND unhappy paths exercised
- [x] scripts still named exactly `lint`, `typecheck`, `test`, and `e2e`
- [x] key read via the two-prefix fallback chain; envPrefix consistent; nothing hardcoded; no secret in code
- [x] irreversible actions guarded + idempotent + flagged
- [x] no avoidable debt; memory updated and pruned
- [x] migrations explained in plain English
- [x] reviewers ran — `.claude/review/*` verdicts refreshed this PR
- [x] every subagent dispatched on a model below the orchestrator's — never inherited

## For you
**What changed:** Step 6.7 added to Vite/Astro/SvelteKit to set the Supabase→Vercel integration prefix after the connection exists (step 6.5); cross-prefix fallback chains and "close and reopen the PR" instruction retired from all 4 copies; step 8.2 in all 4 copies now explicitly warns that "Dependabot on self-hosted runners" must be OFF; step 4 scaffold prompt corrected (`runs-on` is not a valid `dependabot.yml` field); step 5.1 corrected (Supabase does not prompt for GitHub repo during New Project creation — that's step 5.6).
**What you do next:** Review the diff, then merge into `main`. In your own Supabase project, go to Settings → Integrations → Vercel → Manage and set Prefix to `VITE_` (since Dinh-Ngoc-Edu is a Vite app); after that, remove the `NEXT_PUBLIC_` fallback chain from `supabaseClient.ts` and `vite.config.ts` in a separate PR into that repo.
**How to roll it back:** Revert this PR; all 4 copies of `01`, `02`, `06`, `07`, plus `MEMORY.md`, return to their pre-PR state.
