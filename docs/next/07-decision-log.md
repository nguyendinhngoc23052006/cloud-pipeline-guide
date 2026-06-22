# Decision log

> **This part guides you to:** understand *why* every part is the way it is — and
> what was tried and rejected — before you change anything. Read this whenever you
> (or the AI) are about to alter the pipeline.

**Editing rule:** the pipeline is one connected line. Change any part only after
verifying it against the platform's **current official docs**, then update every
part that depends on it in the same pass — never patch one pipe alone, never from
memory. **Write in this document's style:** numbered actions first, then one
plain-language *note*; strictly linear (each step uses only earlier steps); no
bloat; at least as easy to understand as it is now — if an edit reads harder than
what it replaces, cut it. **Arrows (→) may only connect literal on-screen labels**
(buttons, menus, page names); everything else — what to find, judge, or do — must
be a full sentence with a verb, never a fragment like "→ last good →". **Anything
needed to act appears exactly where it's used** — a prompt sits directly under the
line that says to paste it; a value is named in the action that uses it; the
reader never scrolls to find what a sentence references. Pointers to elsewhere are
allowed only when inlining would duplicate a whole section (e.g. recovery lives in
Part 4, not inside the daily flow). **Every ↑ Upgrade must be one Claude Code
prompt away from working (getting a key is fine) and deliver real benefit; if it
needs annoying setup for marginal gain, leave it out.**

- **One production branch, gated by PRs.** This is the platforms' native model
  (Supabase makes a preview branch per PR and deploys to production on merge;
  Vercel mirrors it). A separate long-lived *staging* branch was rejected — it
  isn't in the model and drifts from production.
- **Migrations are truth; fix-forward; empty project.** Production history always
  equals the repo; never edit a merged migration — add a new one.
- **Two keys**, publishable (browser) and secret (Supabase-only).
- **Setup ordered by dependency:** a thin baseline merges *un-gated* (the gates
  need the app it creates); the gate goes up once the checks exist; the first
  gated change is the project structure. This window exists only in the first
  project — a templated repo (step 12) has all files on `main` before its first
  PR, so its gate is active from the start.
- **The template is the baseline, never a finished app.** Migrations, feature
  code, and memory are project-specific; templating them would replay one app's
  schema onto every new project. Templates copy files, not settings — so the
  ruleset rides as committed JSON (one-click import) and the dashboards are redone
  per project.
- **Env-var seam:** the client reads a single set of `NEXT_PUBLIC_` names — Next
  exposes them to the browser natively, and they are the SAME names the integration
  injects into previews, so production (set by hand, Production-scoped) and previews
  need NO fallback and NO `envPrefix` config (the Vite two-prefix workaround does not
  exist here — Next.js is the integration's native case). Only **Production**-scoped
  secrets are deleted from Vercel by hand (the integration's branch-scoped preview
  copies clean themselves up). The old per-connection prefix setting and "sync to
  Preview" toggle no longer exist in the integration UI.
- **Checks:** a `main` ruleset requires a PR + 1 approval + green checks (`tests`,
  `lint`, `typecheck`, `e2e` from GitHub Actions, **Supabase Preview**, and **Vercel** —
  picked under the picker's **Suggestions**, never **Vercel Preview Comments**).
  The approval is what stops Claude merging its own PR.
- **Review is layered, opt-in past the floor:** the orchestrator dispatches an
  in-build review swarm (subagents a tier below the orchestrator, the model passed
  explicitly) before the PR and records each verdict to `.claude/review/`, which
  the Stop hook requires refreshed every PR — invocation is enforced by a
  committed artifact, not hoped; a `researcher` worker one tier below the
  reviewers carries the bulk reading/drafting while the orchestrator decides and
  commits. The **production uptime monitor is core** — it needs no secret
  (production isn't auth-protected), so the only-prompts-and-clicks rule admits
  it; it ships dormant in the template (guards on the `PRODUCTION_URL` variable)
  and never fails a fresh repo. ("Monitor" = scheduled production watcher filing
  issues; "canary" = the preview PR check — one word per mechanism.) The CI
  auto-review and the **preview** canary stay one-prompt upgrades because each
  needs a pasted key/token — review comment-only/advisory; preview canary
  deterministic/required if added. Manual `/verify` and `/test` stay for on-demand
  checks. CI secrets live only in GitHub Actions.
- **CLAUDE.md is a read-only constitution**; Claude flags gaps, you edit.
  Three-tier memory (repo/folder/agent); self-improvement enforced by hooks (block
  at task end, never mid-edit).
- **Constitution meta-behavior layer (Jun 2026).** The rules-for-Claude block was
  tightened with a new `## How you communicate` section (output-density floor) plus
  extensions to `Think first` (verify-before-asserting; file-existence and
  partial-recognition checks), `Simplicity` (code-floor — no comments unless the
  *why* is non-obvious, validate at system boundaries only, no backwards-compat
  shims — plus effort scaling: 1 tool call for a single fact, 3–5 medium, 5–10
  cross-file, 20+ decompose), `Your place + every-PR rules` (Action care: weigh
  reversibility and blast radius; past approval ≠ standing authorization;
  root-cause not shortcut), and `Agents, plugins, MCP` (Skill-first: read
  `SKILL.md` before invoking a verb). Drawn from a review of the Claude Fable 5
  system prompt. The PR-body bullet was tuned to harmonize with the existing
  `## For you` block: intent + impact go above it; the block's headings carry the
  structured what/next/undo. Byte-identical across all 4 framework copies.
- **Skills, not legacy commands:** `/prototype`, `/test`, `/verify`, `/revert` are
  `.claude/skills/<name>/SKILL.md` — invoked as `/name` and auto-invocable by
  Claude.
- **Models by capability tier, never by name — resolved live, never stored.**
  `CLAUDE.md` fixes only roles (orchestrator = the human-chosen session model;
  reviewers a tier below it; worker a tier below them); the orchestrator resolves
  "a tier below me" from its current in-context lineup at dispatch and stores no
  model name anywhere — so a changed lineup *or a tier rename* needs zero edits. A
  stored ladder or frontmatter pin was rejected for exactly this reason: any
  hardcoded name breaks the day a tier is renamed. The one operational rule that
  makes it safe: **on every dispatch pass the `model` explicitly — omitting it
  inherits the orchestrator's tier.** Field-corrected Jun 2026: PR #33's three
  reviewers silently ran the orchestrator's top tier because the dispatch
  *omitted* the model param (omit = inherit); the rule was right, the dispatch was
  not — fixed by always passing the lower tier.
- **Structural change is intent-addressed and confirm-gated.** The resolve→confirm
  protocol lives once in `CLAUDE.md` and in full in "Keeping it current"; each
  part's setup step carries a one-line *Customize it later* pointer to the matching
  "Keeping it current" section rather than restating the prompt, so the management
  prompts live in exactly one place and can't drift from their setup step. A CRUD
  request must resolve to the named file and confirm before deleting, so it can't
  take out the wrong component, and the Stop hook hard-protects the three-reviewer
  floor by filename. Kept separate from the
  currency/update prompt by **verb, not addressing**: both resolve my intent to
  the named file and confirm, but currency only *refreshes an existing part to
  current docs* while CRUD *adds, changes, or removes* one.
- **Rejected:** secrets in the sandbox; write-capable MCP to production; Claude
  self-merging; installing `gh` in setup (needs a setup script + a token in the
  env box, both forbidden by steps 2.4–2.5 — instead the Stop hook verifies a
  committed artifact, `.claude/pr-body.md`, so it needs no GitHub access at all:
  enforcement stays hard in any sandbox, and a fail-open hook that merely warns
  was rejected as enforcement theater); and upgrades that need heavy setup for
  marginal gain (a standing-staging second DB).
- **Testing is layered like review, and every testing rule is verifiable.** Typed
  mocks make schema drift a `typecheck` failure (a mock shaped by hand can lie; a
  typed one can't); path-named tests make unhappy-path coverage greppable; the
  code-reviewer mechanically flags untested service changes; coverage is a printed
  signal, never a threshold gate (thresholds breed test theater — rejected); Edge
  Functions' pure logic is extracted into helpers and tested with **Vitest in the
  existing `tests` job** via `npm:`-specifier aliasing in the Vitest config `vitest.config.ts` (kept in
  lockstep with the functions' `npm:` versions) — so it needs no Deno and no
  separate job, **retiring the old "Deno not in the sandbox" exception** (real
  `deno test` in-sandbox is now reachable by allowlisting `deno.land`, but it
  duplicates that coverage). A **mocked-network Playwright `e2e`** layer is the
  required gate for the UI/flow regressions unit tests miss — deterministic,
  secret-free, and (now that the cloud egress allowlist closed the install gap)
  runnable in-sandbox; a *seeded-preview* Playwright run stays an optional,
  token-gated upgrade. Rejected for marginal gain: mutation testing, snapshot
  tests, test-data factories, coverage gates.
- **Maintenance claims carry Verified stamps.** "Keeping it current" once said
  "re-check every few months" — a vague spec this document's own rule forbids. Now
  every decaying claim is stamped (date + docs/field) and the Routine's monthly
  dated report is the refresh artifact (the human copies verdicts into the
  stamps); a stamp older than ~6 months is treated as unverified. The original
  single-file guide deliberately lived in no repo; this repository *is* that guide,
  committed so the user and the AI can work from it — only the pipeline's
  *outputs* (the app's CLAUDE.md, workflows, the ruleset JSON) are committed into
  the user's own project.
- **Instructions to Claude use measurable triggers and verifiable artifacts, never
  judgment-phrases.** A rule Claude can't test ("don't overcomplicate") becomes
  concrete limits (no abstraction before the second use); a contract a hook can't
  verify ("the self-check ran") becomes an artifact it can (the `## Self-check`
  checklist in the PR body). Vague specifications are automation that silently
  doesn't happen.
- **Rejected — GitHub's "Automatically delete head branches":** deleting a merged
  branch breaks a live Claude Code session still working on it (a filed
  work-continuity bug). Cleanup is therefore **inactivity-only** (7+ days of no
  commits, no open PR) — recency, not merge status, is the safety signal.
- **Merge discipline — field-corrected Jun 2026 (live incident).** A
  presentational PR merged "green" yet production showed no change and was
  reverted. Two causes, now reflected in Part 3's Ship note and step 9's ✓: (1)
  the merge happened the moment the quick jobs passed, *before* the slower
  **Supabase Preview** check had reported (it failed minutes later) — a
  not-yet-reported check can't block a forced-early merge, and on that **private**
  repo the ruleset wasn't hard-enforcing (Pro/Team only); (2) two edits committed
  straight to `main` in the browser (the app's own `CLAUDE.md`) each triggered a
  production build, and the older one promoted *after* the merge's build, so
  production served the pre-merge tree. Fix is documentation-only — wait for every
  check, never edit `main` directly. (The post-merge Supabase Preview failure
  itself couldn't be root-caused — branch logs expire after 24h; the lingering
  merged branch is the deliberate 7-day window above, not a fault.)
- **Verified pass (Jun 2026, official docs):** Vercel's production branch moved to
  **Settings → Environments → Production → Branch Tracking** (vercel.com/docs/git).
  Vercel **Deployment Checks** (vercel.com/docs/deployment-checks) are a
  *post-merge* release gate that imports GitHub checks — they are not PR checks and
  there are no native lint/typecheck toggles, so lint/typecheck run as GitHub
  Actions jobs and the import is offered as the step 9 upgrade. The Supabase→Vercel
  integration exposes no prefix or "sync to Preview" setting; it injects fixed
  `NEXT_PUBLIC_` names at PR-open and auto-redeploys the PR's latest deployment
  (supabase.com/docs/guides/deployment/branching/integrations) — the manual
  redeploy-on-race workaround retired. Field-verified on a live setup: sync fires
  at PR-open **only**; injected vars are branch-scoped and deleted at PR
  close/merge; the integration also syncs branch-scoped secret-tier keys
  (acceptable — ephemeral and browser-unreachable), so only **Production**-scoped
  secrets are deleted by hand; "Supabase changes only" skips branch creation for
  code-only PRs; an orphaned Supabase↔Vercel connection shows no error anywhere —
  its only symptoms are absent branch-scoped vars during an open PR and a missing
  auto-redeploy.
- **Playwright E2E in the cloud sandbox — verified Jun 2026 (field + docs).** With
  **Network = Custom** + the default-package-managers box ticked +
  `cdn.playwright.dev` added (code.claude.com/docs/en/claude-code-on-the-web §
  Network access: Trusted is a fixed list, only Custom takes additions, and the
  checkbox keeps the defaults so `npm ci` still works), Chromium both installs and
  launches on the image's existing libraries — no apt. So a mocked-network `e2e`
  job is a required check, and the install host is logged in the workaround table
  (it retires if `cdn.playwright.dev` joins the Trusted defaults). `deno.land` is
  not in the Trusted defaults either, so real `deno test` in-sandbox would need its
  own allowed-domain entry — not adopted, since vitest-aliasing already covers the
  Edge Functions' pure logic.
- **Seeded demo user must be GoTrue-shaped — verified Jun 2026 (field).**
  Hand-inserting an `auth.users` row for preview-branch login is fine, but its text
  token columns (`confirmation_token`, `recovery_token`, `email_change`,
  `email_change_token_new`) must be `''`, never NULL — GoTrue scans them into
  non-null Go strings, so a NULL surfaces only when someone logs in, as "Database
  error querying schema". The seed also `UPDATE`s those columns from NULL to `''`
  for the seeded email, so a branch created by an older seed self-heals on its next
  run. (Symptom that pins it: a user who signs up through `signUp()` logs in fine
  while only the hand-seeded demo user fails — the malformed row, not the auth
  flow.)
- **The demo seed is "infinite everything" for preview testability, and that's
  safe by construction.** A fully loaded demo user (credits, owned cosmetics/food,
  a menagerie, one public course covering every question kind) makes a fresh
  preview explorable by a human reviewer and by the optional seeded-preview
  Playwright run. The mandatory `e2e` gate stays **mocked-network**
  (seed-independent, deterministic). The weak credential and god-mode balances
  never reach production because `seed.sql` runs only on preview-branch resets, not
  on production deploy, and previews sit behind Vercel Authentication — so the same
  data must never be placed in a migration.
- **Dashboard branching (no Git) rejected — verified Jun 2026**
  (supabase.com/docs/guides/deployment/branching/dashboard, now labeled beta). It
  inverts the model: schema lives only in databases and a computed diff at merge,
  not in migration files — so Claude can't propose schema through PRs, the GitHub
  gate never sees schema changes, and rollback has no file to revert. Its
  documented limits: merge-to-main only, "update branch" overwrites all Edge
  Functions, manual conflict resolution, custom roles lost at branch creation. This
  pipeline stays on the GitHub integration (the GA, recommended workflow); its
  **Supabase Preview** PR check *is* the branching check. The documented drift
  causes — edited migrations silently skipped, sibling previews stranded by a
  merge, hand edits to production — are each blocked by an existing rule: never edit
  a merged migration, one schema change in flight, never touch a DB by hand.
- **Biome replaces ESLint + Prettier (Jun 2026, biomejs.dev).** Single binary, one `biome.json` config, ~10–25× faster than ESLint + Prettier in CI. The `lint` script runs `biome check .` (read-only, CI-safe); `biome check --write .` fixes locally. Type-aware TS coverage is partial — no official overall percentage published by the team; individual rule detection can be as low as 75% for specific rules — accepted because the gap is narrow for standard TypeScript apps and the speed and simplicity gains are significant. The `lint` script name is unchanged; it remains the CI contract.
- **Depot as an opt-in CI accelerator (Jun 2026, depot.dev/docs/github-actions/overview).** Added as an ↑ Upgrade in step 8, not a core step: it requires a separate account and pricing varies by plan for private repos. The integration is one `runs-on` label change per job (`ubuntu-latest` → `depot-ubuntu-latest`); no workflow logic changes. Verified figures from that doc: up to 3× faster build execution; cache upload/download at ~1,000 MiB/s vs GitHub's ~145 MiB/s (10× faster throughput); sub-5-second runner startup.
- **Next.js copy — framework deltas (Verified Jun 2026, official docs).** This is the Next.js edition of the guide. What differs from the
  Vite baseline, and why: the public prefix is `NEXT_PUBLIC_`, which Next exposes to the
  browser natively AND which is exactly what the Supabase→Vercel integration injects into
  previews — so production and previews share one set of names and the Vite two-prefix
  fallback / `envPrefix` workaround is **removed**, not adapted (its workaround-table row
  is gone here, and the routine in step 11 drops that item). Supabase is reached through
  `@supabase/ssr` — a browser `createBrowserClient` plus a server `createServerClient`
  reading cookies, with `middleware.ts` refreshing the session — instead of a single
  browser singleton; there is **no `vercel.json`** (Vercel builds Next natively; the SPA
  catch-all rewrite is Vite-only); Edge-function `npm:` aliasing lives in
  `vitest.config.ts`. Verified against nextjs.org/docs (any `NEXT_PUBLIC_`-prefixed var is
  browser-native, no config), supabase.com/docs/guides/auth/server-side/nextjs
  (createBrowserClient + createServerClient with `cookies()` getAll/setAll + middleware),
  and Vercel's zero-config Next detection. *(Open currency note shared by all copies:
  Supabase is renaming the `anon` key to `sb_publishable_…` — projects after Nov 2025 lack
  the legacy anon key and the integration's injection of the new name has an open bug
  (#38984); the client's `…PUBLISHABLE_KEY ?? …ANON_KEY` read covers both. Tracked in
  MEMORY.md.)*
