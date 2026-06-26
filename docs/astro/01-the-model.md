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
  that the integration syncs are fine — step 6.7 explains.)
- **Tools enforce** — GitHub blocks unreviewed or failing merges, Vercel blocks
  bad builds, Supabase rebuilds from the files, and a committed Stop hook polices
  Claude's own checklist locally.

**The env-var names are a contract.** Astro reaches Supabase on the SERVER (its SSR
middleware reads `process.env`), so it reads `PUBLIC_SUPABASE_URL` (and the key)
directly — `PUBLIC_` is what you set by hand in Vercel (production), and step 6.7
sets the integration's prefix so previews inject the same `PUBLIC_`-named vars. A
client island that needs Supabase gets the public URL + key passed down from the
server. The contract lives in the Supabase client + `src/middleware.ts`,
`.env.example`, and the Vercel production variable names — these all use `PUBLIC_`,
so a change to any one moves all of them in one PR.

**One collision to remember:** Vercel **"Preview"** (a variable *scope*) is not a
PR's **preview** (its live URL).

**Plans:** Supabase **Pro** (Branching needs it) and **Claude Code Pro+** (cloud
sessions) are required; GitHub and Vercel start free.

---

Next: [Part 2 — Set it up →](02-set-it-up.md)
