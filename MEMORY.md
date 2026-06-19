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
  - **Astro**: native `PUBLIC_`; bridge via `astro.config.mjs` `vite.envPrefix:
    ['PUBLIC_','NEXT_PUBLIC_']`, read `PUBLIC_ ?? NEXT_PUBLIC_`.
  - **SvelteKit**: native `PUBLIC_`, but its public `$env` takes one prefix — resolve
    `PUBLIC_ ?? NEXT_PUBLIC_` on the SERVER (hooks.server.ts) and pass the values to
    the browser via the root layout load.

## Quality gate (never skip)
- Verify every platform claim against CURRENT official docs before changing it; carry
  a dated Verified stamp. A stamp older than ~6 months is a question, not a fact.
- Move shared content across ALL framework copies in the same PR (no drift).
- Dispatch the three reviewers + the currency-researcher before any content PR;
  record verdicts to `.claude/review/`.

## Open / to re-verify
- The `next/`, `astro/`, `sveltekit/` env-wiring was written from established
  `@supabase/ssr` patterns and still needs a first official-docs verification pass
  (the org spend limit blocked live web verification at authoring time).
