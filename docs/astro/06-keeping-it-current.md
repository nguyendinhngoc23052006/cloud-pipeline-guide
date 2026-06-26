# Keeping it current

> **This part guides you to:** keep the pipeline current and **manage every part
> of it** — add, update, delete, or refresh any component — after setup. Each
> section below names one kind of part, says where it lives and which setup step
> created it, and gives the exact prompt to change it. Needs Parts 1–2 in place.

The **spine** never changes: migrations as the source of truth, PR → `main`,
required review, two keys + RLS, tools enforcing each other. Everything else
updates — and every claim here decays, so each carries a **Verified** stamp (when,
and how: *docs* = read in the official documentation, *field* = watched happen on
a live setup). **A stamp older than ~6 months is a question, not a fact.**

Every change in this part is still **one PR into `main`** through the same gate —
nothing here bypasses review — and obeys the connected-line rule: a change moves
every part that depends on it in the same PR (later needs earlier).

---

## How each part stays current

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

**Buttons only (no prompt can do these for you):**
- Plan upgrades (GitHub Pro/Team, Vercel Pro, Supabase tiers) — billing pages.
- Dashboard settings (the ruleset, environment variables, deployment checks) —
  each is a click-path already written in its setup step.
- The cloud env's **network access** (Custom mode + allowed domains, e.g.
  `cdn.playwright.dev`) — the **Network access** selector in the environment's
  edit dialog (step 2.3).
- Rotating a key or secret — generate in the owning dashboard, replace where its
  step says it lives.

---

## Managing the parts (add · update · delete)

Find the part you want to change, fill the verb (**add / update / delete**) and
the `<…>` job, and paste. Every prompt resolves your intent to the exact named
file, restates it, and confirms before deleting — so it can never take out the
wrong thing — and moves every dependent part in the same PR.

### CLAUDE.md rules (the project constitution)
*Lives in `CLAUDE.md` at the app repo root · created in step 3.* It is
**read-only** — Claude proposes, you merge; it never self-edits.

```text
Propose a rule change: the CLAUDE.md rule whose job is <…>. Resolve my intent to the exact rule and restate it before editing; if it matches none or several, ask first. Do NOT self-edit the constitution beyond this proposal — open ONE PR into main with the change AND every dependent change (folder CLAUDE.mds, the Self-check, any workflow/agent the rule governs), the Self-check, and the "For you" block. I merge.
```

### Reviewer agents + the researcher worker
*Live in `.claude/agents/` (each with a memory sidecar) · created in step 7.*
Floor that can never be deleted: `security-reviewer`, `code-reviewer`,
`scale-reviewer`.

```text
<Add|Update|Delete> the agent whose job is <…>. Resolve my intent to the exact file at .claude/agents/<name>.md and restate it; if it matches none or several, ask first; confirm before any delete. Never drop below the three-reviewer floor (security, code, scale). Any new agent is least-privilege, model-agnostic (no model named in its file), and keeps its own memory sidecar; a writer agent may only open PRs into main, never merge. Name whatever depended on anything removed. Open ONE PR into main with the Self-check and the "For you" block.
```

### Self-improvement hooks
*Live in `.claude/settings.json` (+ their scripts) · created in step 7.* The
SessionStart hook loads memory; the Stop/SubagentStop hook polices the checklist.

```text
<Add|Update|Delete> the hook whose job is <…>. Resolve my intent to the exact hook in .claude/settings.json (and its script) and restate it; if it matches none or several, ask first; confirm before any delete. Never weaken the Stop hook's gates or the three-reviewer floor it protects; block only at task end, never on file writes; verify only with git and the filesystem (never gh or the network). Open ONE PR into main with the Self-check and the "For you" block.
```

### Command skills
*Live in `.claude/skills/<name>/SKILL.md`, invoked as `/name` · created in step
10* (`/prototype`, `/test`, `/verify`, `/revert`).

```text
<Add|Update|Delete> the skill whose job is <…>. Resolve my intent to the exact .claude/skills/<name>/SKILL.md and restate it; if it matches none or several, ask first; confirm before any delete. A skill is invoked as /name and auto-invocable by Claude; keep its YAML frontmatter (name + proactive description). Open ONE PR into main with the Self-check and the "For you" block.
```

### Workflows (CI and the gates)
*Live in `.github/workflows/` · created in step 8* (`ci.yml` → jobs `tests`,
`lint`, `typecheck`; `branch-cleanup.yml`; `uptime.yml`; `e2e.yml` → job `e2e`;
optional `claude-review.yml`, `canary.yml`).

```text
<Add|Update|Delete> the workflow whose job is <…>. Resolve my intent to the exact .github/workflows/<file>.yml and restate it; if it matches none or several, ask first; confirm before any delete. The job names tests/lint/typecheck/e2e are a CI contract the ruleset requires — if you rename or remove a required job, update it AND tell me to reselect it in the ruleset (step 9) and in Vercel Deployment Checks if I added them, in the same PR. Open ONE PR into main with the Self-check and the "For you" block.
```

### MCP servers (read-only eyes)
*Live in `.mcp.json` (project scope) · added in the step 7 upgrade.*

```text
<Add|Update|Delete> the MCP server whose job is <…>. Resolve my intent to the exact entry in .mcp.json and restate it; if it matches none or several, ask first; confirm before any delete. MCP servers are read-only/observability ONLY — never write, deploy, or merge to production; scope the Supabase server to this project and keep its read-only flag. Open ONE PR into main with the Self-check and the "For you" block.
```

### The env-name contract
*Spans the Supabase client + `src/middleware.ts`, `.env.example`, the Vercel
**Production** variable names, and the prefix in Supabase → Project → Settings →
Integrations → Vercel → Manage · set in steps 4 and 6.* The textbook connected
line: all four use the `PUBLIC_` prefix (step 6.7 configures the integration to inject
`PUBLIC_` into previews, matching production), so a change to any one moves all of them
or none.

```text
Change the env-name contract: <what you're changing>. Move ALL of it in ONE PR: the server-side resolver (src/middleware.ts + the Supabase client), .env.example, the names I set in Vercel Production, and the prefix in Supabase → Project → Settings → Integrations → Vercel → Manage if the prefix itself changes. In the "For you" block, give me the exact Vercel dashboard clicks for any Production-variable rename. Open ONE PR into main with the Self-check.
```

---

## Renaming the project

Six ordered steps — reconnect the platforms before Claude's file PR, because the
PR prompt names the new repo.

1. github.com → your repo → **Settings** → **Repository name** — type the new
   name → **Rename**.
2. github.com → **Settings → Applications → Claude → Repository access** — add
   the renamed repo → **Save**.
3. Supabase → **Organization → Integrations → GitHub Connections** — remove the
   old repo connection and reconnect to the renamed repo (same path as Part 2
   step 5.6; existing connections silently keep pointing at the old name with no
   error shown anywhere).
4. Vercel → **project → Settings → Git** — disconnect and reconnect to the
   renamed repo.
5. *(Optional — rename the Vercel project to match):* Vercel → **project →
   Settings → General → Project Name** — type the new name → **Save**; then
   update the uptime monitor: GitHub → **Settings → Secrets and variables →
   Actions → Variables → `PRODUCTION_URL`** — replace with the new
   `*.vercel.app` URL.
6. Paste this to Claude:

```text
The project has been renamed to <new-name>. In one PR update every reference to the old name: supabase/config.toml project_id label, package.json name, the app title in index.html and any component that renders it, MEMORY.md, docs/ARCHITECTURE.md, and README.md. Open a PR into main.
```

*Note:* GitHub git redirects break permanently if anyone later creates a new repo
with the old name — update remotes promptly. Your Supabase data is safe; only the
branch sync breaks until step 3 reconnects it. Vercel Deployment Checks don't
need reselecting — they track CI job names, not the project or repo name. *(docs,
Jun 2026)*

---

## Refresh a part to current docs

Use this when a part is structurally fine but may have drifted from the
platforms' current behavior — a pinned reviewer version/model, a dashboard path,
this guide's own claims. It **refreshes**; it does not add, change, or remove
(that's the section above — same resolve-and-confirm, different verb).

```text
Refresh the <agent|skill|hook|workflow|MCP server|CLAUDE.md rule|the env-name contract|a workaround-table row> whose job is <…> to match current official docs — currency only, not a structural add/change/remove. Resolve my intent to the exact named file and restate it before editing; if it matches none or several, ask first. Read the relevant CURRENT official documentation, then open ONE PR into main with the refresh AND every dependent change per CLAUDE.md, the Self-check, and the "For you" block — and in the PR description list each documentation page you read (URL) and quote the sentence that justifies each change, so I can re-stamp this guide's Verified column. If you could not reach the docs, or the update is not real or not safe, open nothing and report why.
```

Run refreshes in the **template repo** too — it's the mold every next project is
cast from. A maintenance promise without an artifact is automation that silently
doesn't happen: the PR's quoted-doc list is that artifact, and you copy its
verdicts into the stamps here.

---

## Workarounds (and when each retires)

These exist only because a platform hasn't closed a gap yet; each retires the day
its **Retire when…** comes true. To retire one, paste the management prompt below
(it removes the code *and* its table row together — the connected-line rule);
without the Routine (step 11), run the refresh prompt on this table every few
months yourself to re-stamp the **Verified** column.

```text
Delete the workaround whose job is <…>: confirm its Retire-when condition is met against current official docs, then in ONE PR remove the workaround's code, every part of the repo depending on it, AND this table's row for it. If the condition is NOT met, open nothing and report why. Open the PR into main with the Self-check and the "For you" block.
```

| Workaround | Retire when… | Then | Verified |
|---|---|---|---|
| auth-seed SQL (GoTrue token columns written `''`, never NULL) + `signUp()` fallback (when you build auth) | Supabase ships **working** preview-branch user creation via the Admin API | seed via the Admin API | field (observed bug — a NULL token column logs in as "Database error querying schema"), Jun 2026 |
| SessionStart hook loading the repo's committed `MEMORY.md` | Claude Code's native **auto memory** (v2.1.59+) syncs across machines — today it is explicitly **machine-local and not shared with cloud environments**, so every fresh cloud sandbox starts amnesiac without the committed file | move repo lessons into native memory and drop the hook | docs, Jun 2026 |
| Custom network mode + the `cdn.playwright.dev` allowed-domain entry (so the sandbox can install Playwright's Chromium) | `cdn.playwright.dev` joins the **Trusted** default allowlist | set **Network = Trusted** and drop the Custom entry | docs + field, Jun 2026 |

---

Next: [Decision log →](07-decision-log.md)
