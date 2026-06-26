# MEMORY.md — working memory for maintaining this guide

Whole-scene facts about THIS guide repo (one fact per line; prune to ~200 lines).
Folder-local conventions live in a folder `CLAUDE.md`; each agent's lessons live in
its `.memory.md` sidecar. The SessionStart hook loads this file — read it at the
start of every task, and record decisions, root causes, and gotchas as you go.

## Structure
- The guide ships one complete copy per framework under `docs/<framework>/`:
  `vite/` (default), `next/`, `astro/`, `sveltekit/` — all four built.
- Parts 03/04/05 are byte-identical across copies; Parts 01/02/06/07 carry the
  framework-specific deltas. The root `README.md` is the framework chooser.

## The one rule above all
- Everything must minimize the human's workload: paste a prompt, click a dashboard,
  copy a key — never a terminal, never local setup. A "better" approach that breaks
  this is rejected no matter how good otherwise.

## Per-framework env wiring (the only real delta)
- The Supabase→Vercel integration's per-connection prefix is configurable (Supabase →
  Project → Settings → Integrations → Vercel → Manage → Customize prefix — step 6.7,
  AFTER step 6.5 installs the marketplace app, because the connection doesn't exist until then).
  Set it to the framework's native prefix; production and preview then share the same names,
  and no cross-prefix fallback is needed.
  - **Vite**: native `VITE_`; step 6.7 sets integration prefix to `VITE_`; `envPrefix:
    ['VITE_']`; read `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY ?? VITE_SUPABASE_ANON_KEY`; no fallback.
  - **Next.js**: native `NEXT_PUBLIC_` — the integration default already matches; no
    change to prefix needed; NO fallback and NO envPrefix.
  - **Astro**: native `PUBLIC_`; step 6.7 sets integration prefix to `PUBLIC_`; SERVER
    (middleware) reads `PUBLIC_SUPABASE_URL` and `PUBLIC_SUPABASE_PUBLISHABLE_KEY ??
    PUBLIC_SUPABASE_ANON_KEY` from `process.env`; passes public values to islands —
    NO `vite.envPrefix` (that override has a known Astro breakage, issue #10406).
  - **SvelteKit**: native `PUBLIC_`; step 6.7 sets integration prefix to `PUBLIC_`;
    SERVER (hooks.server.ts) reads `PUBLIC_SUPABASE_URL` and `PUBLIC_SUPABASE_PUBLISHABLE_KEY ??
    PUBLIC_SUPABASE_ANON_KEY` from `process.env`; passes values via root layout load.

## Quality gate (never skip)
- Verify every platform claim against CURRENT official docs before changing it; carry
  a dated Verified stamp. A stamp older than ~6 months is a question, not a fact.
- Move shared content across ALL framework copies in the same PR (no drift).
- Dispatch the three reviewers + the currency-researcher before any content PR;
  record verdicts to `.claude/review/`.

## Verified / open
- Framework env-wiring **verified Jun 2026** (currency-researcher, official docs):
  Next.js ✓, SvelteKit ✓, Astro ✓ (after correcting its draft — the `vite.envPrefix`
  bridge has a known Astro breakage #10406, replaced by server-side resolution).
- App-constitution **meta-behavior layer added Jun 2026** (drawn from Fable 5 system
  prompt review): new `## How you communicate` section + extensions to `Think first`
  (verify-before-asserting), `Simplicity` (code-floor + effort scaling),
  `Your place + every-PR rules` (Action care), `Agents, plugins, MCP` (Skill-first).
  Byte-identical across all 4 framework copies of `docs/<framework>/02-set-it-up.md`.
- **Verified Jun 2026 — integration injects both key names:** the External Connection
  auto-injects both `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  *(field, Jun 2026; user Vercel dashboard — official marketplace docs list only ANON_KEY,
  so actual injection exceeds the documented list)*. The `…PUBLISHABLE_KEY ?? …ANON_KEY`
  fallback chain covers both; issue #38984 remains open but resolved in practice.
- **Verified Jun 2026 — prefix IS configurable and bridges are retired:** Supabase dashboard
  → Project → Settings → Integrations → Vercel → Manage → Customize prefix — field-verified
  Jun 2026; supabase/supabase PR #28058 merged Jul 2024. Step 6.7 added to all three
  non-Next frameworks (Vite → `VITE_`, Astro → `PUBLIC_`, SvelteKit → `PUBLIC_`; Next.js
  — no change needed); placed after step 6.5 (marketplace install), not step 5. The `NEXT_PUBLIC_` prefix bridge workarounds (fallback chains in Vite/Astro/
  SvelteKit, close/reopen ✗ instruction in all 4) retired in this PR across all copies.
- **Arrow-rule fix Jun 2026:** three `→`-chained bullets in the constitution block of
  `02-set-it-up.md` (Memory "Cycle", "Worked/failed"; Your place "Flow") rewritten as full
  sentences across all 4 framework copies.
- **"Renaming the project" section added Jun 2026** to all 4 `docs/<framework>/06-keeping-it-current.md`
  copies (byte-identical, framework-neutral). Verified: GitHub redirects break if old
  name reused (docs); Supabase branch sync breaks until reconnected via Organization →
  Integrations → GitHub Connections (same path as step 5.6); Vercel Deployment Checks
  unaffected by rename (track CI job names). `*.vercel.app` URL change on Vercel rename
  and Supabase→Vercel integration re-link behavior: not doc-verified (KB 403'd) — step
  5 is marked optional and uses safe "replace with the new URL" framing.
- **Biome replaces ESLint + Prettier Jun 2026** in scaffold prompt (step 4) and E2E
  prompt (step 8.6) across all 4 framework copies. `lint` script name unchanged (CI
  contract). Decision log entries added. Accuracy reviewer flagged: don't assert specific
  biome.json config keys in prompts — let Claude resolve them at scaffold time.
- **Depot CI accelerator added Jun 2026** as an ↑ Upgrade in step 8 across all 4 copies.
  Integration is `runs-on: depot-ubuntu-latest` (label change only). Verified speed:
  3x builds, 10x cache, sub-5s startup (depot.dev/docs/github-actions/overview).
  Editing reviewer flagged: arrows in numbered steps must connect only literal on-screen
  labels — prose after the last label uses semicolon, not arrow.
