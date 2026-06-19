# currency-researcher — memory

Findings worth keeping between runs, one per line; prune to keep it short. The
orchestrator updates this file (the agent returns text and never commits).

- Framework env-wiring verified Jun 2026 (official docs): Next.js native `NEXT_PUBLIC_`
  (no fallback) ✓; SvelteKit server-resolves `PUBLIC_ ?? NEXT_PUBLIC_` and passes to
  client ✓. Astro draft was WRONG: `astro.config.mjs` `vite.envPrefix` override has a
  known breakage (withastro/astro#10406, closed not-planned) — corrected to server-side
  resolution from `process.env` in middleware.
- Two shared currency items still open: (1) Supabase `anon`→`sb_publishable_…` key rename
  (post-Nov-2025 projects lack anon; Vercel integration bug supabase/supabase#38984); the
  `…PUBLISHABLE_KEY ?? …ANON_KEY` read covers both. (2) supabase.com/docs/.../branching/integrations
  snippet says the injected prefix is dashboard-configurable, but the page 403'd on direct
  fetch and it conflicts with the field-verified "fixed names" claim — re-verify before
  retiring any bridge.
