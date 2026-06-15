# Keeping it current

The **spine** never changes: migrations as the source of truth, PR → `main`,
required review, two keys + RLS, tools enforcing each other. Everything else
updates — and every claim in this section decays, so each carries a **Verified**
stamp (when, and how: *docs* = read in the official documentation, *field* =
watched happen on a live setup). **A stamp older than ~6 months is a question, not
a fact.** This guide's claims are re-verified by the Routine (step 11) monthly,
which ends every run with a dated verdict report; copy those verdicts into the
stamps here. A maintenance promise without an artifact is automation that silently
doesn't happen — the report is the artifact.

**Updates itself (you do nothing):**
- The four platforms (GitHub, Supabase, Vercel, Claude Code) — they're hosted
  services.
- The Node version in CI — `lts/*` resolves to the current LTS on every run.
  *(docs, Jun 2026)*
- Supabase preview branches — paused on inactivity, deleted when their PR merges
  or closes. *(docs + field, Jun 2026)*
- The uptime monitor and branch cleanup — scheduled workflows, with two honest
  caveats from GitHub's `schedule` reference: cron runs can be **delayed or
  dropped under load** (treat the monitor as minutes-coarse, not a stopwatch), and
  in a **public** repo GitHub **disables scheduled workflows after 60 days without
  repository activity** (GitHub emails you first; any commit — even a merged
  Dependabot PR — resets the clock, and **Actions → the workflow → Enable** turns
  a disabled one back on). *(docs, Jun 2026)*
- The reviewer/worker model tier — the orchestrator resolves "a tier below itself"
  from its live in-context lineup at dispatch, so it needs **no maintenance across
  version bumps *or* tier renames**; no model name is stored anywhere. *(docs, Jun
  2026)*

**Arrives as a PR (you just review and merge, like any other PR):**
- npm dependencies and GitHub Actions versions — Dependabot opens grouped weekly
  PRs, plus security patches the moment a CVE lands (the step 8.2 toggle is what
  turns those on). *(docs, Jun 2026)*
- Claude's memory and lessons — they ride the PRs Claude already opens.

**One prompt away — the currency prompt; paste it filling both blanks:**

```text
Refresh the <agent|skill|hook|workflow|MCP server|CLAUDE.md rule|the env-name contract|a workaround-table row> whose job is <…> to match current official docs — currency only, not a structural add/change/remove. Resolve my intent to the exact named file and restate it before editing; if it matches none or several, ask first. Read the relevant CURRENT official documentation, then open ONE PR into main with the refresh AND every dependent change per CLAUDE.md, the Self-check, and the "For you" block — and in the PR description list each documentation page you read (URL) and quote the sentence that justifies each change, so I can re-stamp my guide's Verified column. If you could not reach the docs, or the update is not real or not safe, open nothing and report why.
```

It **refreshes an existing part to current**: the pinned reviewer
(`claude-code-action` version and its model — pinned on purpose, bumped when *you*
decide); a framework swap (the env-name contract — `envPrefix`, client,
`.env.example`, Vercel production names — moves in one PR); a `CLAUDE.md` rule;
this guide itself; or a workaround row. To **add, change, or remove a part** —
agent, skill, hook, workflow, MCP server, or rule — use that part's
intent-addressed *Customize it* prompt under its setup step instead: same
resolve-and-confirm, different verb. Run updates in the **template repo** too —
it's the mold every next project is cast from.

**Buttons only (no prompt can do these for you):**
- Plan upgrades (GitHub Pro/Team, Vercel Pro, Supabase tiers) — billing pages.
- Dashboard settings (the ruleset, environment variables, deployment checks) —
  each is a click-path already written in its setup step.
- The cloud env's **network access** (Custom mode + allowed domains, e.g.
  `cdn.playwright.dev`) — the **Network access** selector in the environment's
  edit dialog (step 2.3).
- Rotating a key or secret — generate in the owning dashboard, replace where its
  step says it lives.

**Workarounds** — these exist only because a platform hasn't closed a gap yet;
each retires the day its **Retire when…** comes true. The Routine re-checks this
table monthly against current official docs and reports a verdict per row — copy
its verdicts into the **Verified** column here; without the Routine, run the
update prompt on this table every few months yourself.

| Workaround | Retire when… | Then | Verified |
|---|---|---|---|
| `NEXT_PUBLIC_` fallback chain in `supabaseClient` + the extra `envPrefix` entry | the Supabase→Vercel integration lets you choose the injected variable names (so previews can receive `VITE_…PUBLISHABLE_KEY`) | read only the `VITE_` names and drop `NEXT_PUBLIC_` from `envPrefix` | docs + field, Jun 2026 |
| close/reopen the PR to retrigger env sync after fixing a connection | the integration syncs on push/branch creation, not only at PR-open | drop the reopen instruction from step 6's ✗ | field, Jun 2026 |
| auth-seed SQL (GoTrue token columns written `''`, never NULL) + `signUp()` fallback (when you build auth) | Supabase ships **working** preview-branch user creation via the Admin API | seed via the Admin API | field (observed bug — a NULL token column logs in as "Database error querying schema"), Jun 2026 |
| SessionStart hook loading the repo's committed `MEMORY.md` | Claude Code's native **auto memory** (v2.1.59+) syncs across machines — today it is explicitly **machine-local and not shared with cloud environments**, so every fresh cloud sandbox starts amnesiac without the committed file | move repo lessons into native memory and drop the hook | docs, Jun 2026 |
| Custom network mode + the `cdn.playwright.dev` allowed-domain entry (so the sandbox can install Playwright's Chromium) | `cdn.playwright.dev` joins the **Trusted** default allowlist | set **Network = Trusted** and drop the Custom entry | docs + field, Jun 2026 |

---

Next: [Decision log →](07-decision-log.md)
