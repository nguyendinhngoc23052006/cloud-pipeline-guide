# Part 1 — The model

> **This part guides you to:** understand how the pipeline works and the five
> rules that hold it together — so the setup steps make sense. Everything later
> depends on this; read it first.

> Read **Part 1** once, do [**Part 2**](02-set-it-up.md) once (top to bottom),
> then live in [**Part 3**](03-ship-a-feature-daily.md). In every step the
> **numbered lines are the actions**; the italic *note* under them is the one
> thing worth knowing. **↑ Upgrade** notes are optional add-ons you can do later.

You manage one long-lived branch, `main` (production). Everything else is a
throwaway `claude/…` branch that becomes a PR.

```
   CLAUDE CODE  (you describe a task)
        │  opens a PR into "main"  (from a claude/… branch)
        ▼
  ┌───────────────────────────┐   each PR → its own preview DB + URL
  │       Pull request        │ · · · · · ·▶  (test here)
  └─────────────┬─────────────┘
        │  you review + merge   (Claude can't merge)
        ▼
  ┌──────────────┐
  │     main     │ ──────▶  live site (production DB)
  └──────────────┘
```

**Five rules that make it work:**
- **One production branch** — `main`. The `claude/…` branches are scratch;
  "preview" and "production" are *stages*, not branches you type.
- **Claude proposes, never merges** — your reviewed merge is the only path to
  production.
- **Migrations are the source of truth** — every DB change is a SQL file; you
  never hand-edit a database.
- **Two keys** — the *publishable* key is browser-safe; the *secret* key is
  server-only and you never paste it anywhere. (The branch-scoped preview copies
  that the integration syncs are fine — step 8 explains.)
- **Tools enforce** — GitHub blocks unreviewed or failing merges, Vercel blocks
  bad builds, Supabase rebuilds from the files, and a committed Stop hook polices
  Claude's own checklist locally.

**The env-var names are a contract.** The browser only sees variables prefixed
`NEXT_PUBLIC_` — Next exposes them with no config. Here the seam is seamless: the
two values you set by hand in Vercel (production) carry the SAME names the Supabase
integration injects into previews — `NEXT_PUBLIC_SUPABASE_URL` and
`NEXT_PUBLIC_SUPABASE_ANON_KEY` — so the client reads one set of names everywhere,
with no fallback. (Next.js is the case the Supabase→Vercel integration was built
for; a fallback exists only to bridge a prefix mismatch, and here there is none.)
The contract lives in the Supabase client files, `.env.example`, and the Vercel
production variable names — they name the same two values, so a change to any one
moves all of them in one PR.

**One collision to remember:** Vercel **"Preview"** (a variable *scope*) is not a
PR's **preview** (its live URL).

**Plans:** Supabase **Pro** (Branching needs it) and **Claude Code Pro+** (cloud
sessions) are required; GitHub and Vercel start free.

---

Next: [Part 2 — Set it up →](02-set-it-up.md)
