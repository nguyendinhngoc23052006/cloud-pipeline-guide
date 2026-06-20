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
- The Supabase→Vercel integration injects fixed `NEXT_PUBLIC_SUPABASE_URL` /
  `NEXT_PUBLIC_SUPABASE_ANON_KEY` into each preview; production names are set by
  hand. So the client must read both.
  - **Vite**: native `VITE_`; bridge previews via `envPrefix: ['VITE_','NEXT_PUBLIC_']`,
    read `VITE_ ?? NEXT_PUBLIC_`.
  - **Next.js**: native `NEXT_PUBLIC_` — production AND preview share these names, so
    NO fallback and NO envPrefix; the Vite workaround does not exist here.
  - **Astro**: native `PUBLIC_`; the SERVER (middleware) resolves `PUBLIC_ ?? NEXT_PUBLIC_`
    from `process.env` and passes public values to islands — NO `vite.envPrefix` (that
    override has a known Astro breakage, issue #10406).
  - **SvelteKit**: native `PUBLIC_`, but its public `$env` takes one prefix — resolve
    `PUBLIC_ ?? NEXT_PUBLIC_` on the SERVER (hooks.server.ts) and pass the values to
    the browser via the root layout load.

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
- **Open currency items (shared — for a follow-up refresh, affect the merged Vite copy too):**
  (1) Supabase is renaming `anon`→`sb_publishable_…`; post-Nov-2025 projects lack the
  legacy anon key, and the Vercel integration's injection of the new name has open bug
  #38984 — the client's `…PUBLISHABLE_KEY ?? …ANON_KEY` read covers both today.
  (2) A search snippet suggests the integration's injected prefix may be configurable in
  the Supabase dashboard (direct doc fetch 403'd) — would retire the bridge workaround, but
  CONFLICTS with the field-verified "fixed names" claim, so re-verify before acting.
- **Open editing item (follow-on PR):** pre-existing arrow-rule violations in the
  constitution block, identical across all 4 framework copies, at
  `02-set-it-up.md:140` (Memory "Cycle"), `:141` (Memory "Worked/failed"), `:144`
  (Your place "Flow"). Flagged by editing-reviewer Jun 2026 as CONCERN, out of
  scope of the meta-behavior-layer PR; rewrite as full sentences with verbs.
