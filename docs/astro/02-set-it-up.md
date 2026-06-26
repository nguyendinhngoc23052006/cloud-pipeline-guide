# Part 2 — Set it up

> **This part guides you to:** wire GitHub, Claude Code, Supabase, and Vercel
> into one gated pipeline, in 14 dependency-ordered steps. Needs Part 1's model.
> Every later part assumes this is done.

> One-time setup. Do the steps **in order**; don't start one until the last
> step's **✓** passes. Every step is repeatable. Numbered lines are actions; the
> italic *note* is the one thing worth knowing.

You're wiring four tools into one line — authorize each link once and they run
themselves afterward. Steps 1–13 build your first project *and* the reusable
template; step 14 makes every next project a 30-minute recipe.
- **Claude Code ↔ GitHub** — Claude opens PRs (the GitHub App).
- **repo ↔ Supabase** — every PR gets its own preview database; merging migrates
  production.
- **app ↔ Supabase, through Vercel** — the integration injects each PR preview's
  URL + key (production's two values you paste by hand).
- **a `main` ruleset** — the gate that blocks any unreviewed or failing merge.

**The only values you copy by hand:**

| Value | Where to get it | Where it goes |
|---|---|---|
| Project URL + publishable key (`sb_publishable_…`) | Supabase project **home page → Copy ⌄** | Vercel, **Production** scope |
| Secret key (`sb_secret_…`) | Supabase only | you never paste it anywhere — never code, Git, or Production-scoped Vercel (step 8.4) |
| Project ID / DB password | — | never pasted into the pipeline (keep the password in your password manager) |

## 1. Create the GitHub repo
1. github.com → **New repository** → name it, set **Private**, check **Add a
   README** → **Create**.

*Note:* the README gives `main` a first commit for Claude to branch from. Turn on
**MFA** for your GitHub account (Settings → Password and authentication) — it
guards the account that controls everything else. Free branch protection needs a
*public* repo — to stay private, use GitHub Pro/Team.

## 2. Connect Claude Code
1. Open Claude Code (claude.ai/code or the desktop **Code** tab); authorize the
   **Claude GitHub App** — and on GitHub's install screen, choose **Only select
   repositories → this repo** (a cloud session can reach any repo the connection
   can see, so grant it just this one).
2. Use a **Remote (cloud)** environment; start sessions from **`main`**; turn on
   **plan mode** (the mode picker in the prompt box — in the CLI, Shift+Tab
   cycles to it); run the session on the **most capable model** — this is the one
   place a model is chosen: it sets the **orchestrator's** tier, and the
   orchestrator dispatches every subagent (step 9) on a tier below itself.
3. Set **Network = Custom**; tick **Also include default list of common package
   managers** (this keeps the Trusted defaults — npm, PyPI, GitHub, cloud SDKs —
   so `npm ci` still works) and add `cdn.playwright.dev` to **Allowed domains**
   (the sandbox installs Playwright's Chromium from it for the E2E suite, step
   10.6). Allowlist changes apply only to newly-created containers, so set this
   before the session that builds step 10; Trusted is a fixed list that can't take
   additions, which is why this uses Custom.
4. **Leave the setup script empty** — the image already has Node/npm and `npx`
   fetches the Supabase CLI; a failing `npm install` here breaks startup.
5. No secrets in the env box; commit the `.claude/` folder.
6. In Claude Code **Settings**, enable **Automatically create PR** (Claude opens
   the PR itself when a task ends, without a second prompt) and **Auto-fix PR**
   (Claude watches its open PRs and pushes a fix when CI fails).

*Note:* Claude works in a disposable sandbox — it branches off `main` and opens
PRs but can't merge.

**✓** ask it to "add a one-line comment to the README" — within a minute a PR
appears from a `claude/…` branch. If no PR appears, re-authorize the GitHub App.

## 3. Create the Supabase project
1. supabase.com → **New project**; save the **database password** (you won't see it
   again); pick the nearest region.
2. Make sure it's a **brand-new, empty project**.
3. Upgrade to **Pro** (Settings → Billing).
4. On the project **home page**, click **Copy ⌄** next to the URL; copy the
   **Project URL** and **publishable key**.
5. **Settings → Add-ons → Point-in-Time Recovery →** enable.

*Note:* the project must start **empty** — Supabase Branching replays your
migration files onto a fresh copy for every PR, and it can't do that if the
schema already exists. The database password is shown only once; store it in your
password manager now. If you ever recreate the Supabase project or rename the
repo, redo step 6 and steps 8.1–8.3 — existing connections silently keep pointing
at the old identity and sync nothing, with no error shown anywhere.

**✓** the project home page shows the Project URL and publishable key you copied
in step 3.4.

## 4. Create the rulebook
1. In Claude Code, paste this:

```text
Create CLAUDE.md at the repo root with the content below, and an empty MEMORY.md. Open a PR into main.
```

2. As your next message, paste this block:

````markdown
# CLAUDE.md — project rules

You are the senior DevOps engineer and **orchestrator** of four tools as one system: GitHub (gates), Supabase (DB via migration files), Vercel (deploy + checks), and you (the orchestrator and final writer — lesser-tier worker agents may read and draft, but only you review, fix, and commit). A change isn't done until the code, its migration, `src/types`, any env/secret, and the docs all agree in one PR.

## How you work (4 principles)
1. **Think first.** Restate the goal (ask if it differs from mine); read the files and their callers before editing; state assumptions in the PR. Ask ONE question first when the task crosses any of these lines: touches more than 5 files · adds the project's first use of a new dependency, top-level folder, or external service · includes a migration touching more than one table. **Verify before asserting:** stable facts (syntax, this repo's code) — answer from what you read; mutable facts (platform docs, library APIs, dashboard paths) — check the source. A prompt implying a file exists doesn't mean it does — check. Partial recognition of a name or version is not current knowledge.
2. **Simplicity.** Minimum code, nothing speculative. Concretely: no new dependency unless the task names one or it removes meaningful code; no abstraction (helper, wrapper, base class, generic) until the SECOND real use exists; no config option, flag, or prop for behavior with exactly one caller; no error handling for states the code cannot reach. **Code-floor:** default to no comments — add one only when the *why* is non-obvious (hidden constraint, bug workaround); names already say *what*. Validate at system boundaries only (user input, external APIs, webhooks) — trust framework and internal-code invariants. No backwards-compat shims for unused code — delete it. **Effort scaling:** 1 tool call for a single fact; 3–5 for a medium change; 5–10 for cross-file work; 20+ means decompose the task and ask before charging in. Run independent reads in parallel; sequence dependent ones.
3. **Surgical.** Touch only what the task needs; match existing style; note unrelated problems instead of fixing them; remove only orphans you created.
4. **Goal-driven.** Turn the task into a test (write the failing test, then pass it). Verify signatures/versions/columns against real code. After two failed tries, report instead of thrashing.

## How you communicate
- **Density first.** No intros, conclusions, or conversational filler.
- Assume **advanced context** — never re-state what I established this turn.
- **Bold** key terms; **bullets** for lists; **prose** for reasoning. Never bullet a refusal.
- Code references as `path/file.ts:line` — never paraphrased.
- **One sentence** of intent before the first tool call.
- **One sentence** at each finding, pivot, or blocker. Silent otherwise.
- **One question max** per turn, only after attempting the ambiguous case yourself.
- Mistakes: **own in one line, fix in the next.** No apology cascade, no surrender.
- Length tracks task: a one-line ask gets a one-line answer. Padding for "thoroughness" violates the floor.
- End-of-turn: **what changed + what's next**, two sentences max.
- PR body: brief **intent + impact** above the `## For you` block; the block's headings carry the structured what/next/undo. Don't restate the diff in prose.
- Tool-result echoing forbidden — synthesize, don't quote.

## Security
- RLS on every table; a user touches only their own rows; never trust the client.
- Validate every input server-side in `src/services/`.
- Auth, money, PII, uploads: state the abuse case and how you block it, in the PR.
- The browser gets only the publishable key; never reference a secret key in client code.

## Architecture & structure
- One responsibility per file, ~200 lines; edit before creating.
- A startup failure (e.g. missing Supabase config) renders as visible text in the page, never a blank screen — a deployment never shows a blank page.
- Components render UI; data access and validation live in `src/services/`.
- Read Supabase config on the SERVER (in `src/middleware.ts`, from `process.env`): read `PUBLIC_SUPABASE_URL` and `PUBLIC_SUPABASE_PUBLISHABLE_KEY ?? PUBLIC_SUPABASE_ANON_KEY` (step 8.3 configures the integration to inject `PUBLIC_`-named vars into previews, matching production). A client island that needs Supabase gets the public URL + key passed from the server, never reading env itself. Never hardcode. The contract spans the Supabase client + `src/middleware.ts`, `.env.example`, and the Vercel production variable names — all using `PUBLIC_`; if the stack changes, move all of it in ONE PR.
- Folders: `src/pages` (routes + endpoints) · `src/components` (UI) · `src/hooks` (logic) · `src/services` (data + validation) · `src/lib` (incl. the Supabase client) · `src/middleware.ts` (server client + session on `locals`) · `src/types` · `supabase/migrations` (one SQL file per change) · `supabase/config.toml` · `supabase/seed.sql`.
- **Designing structure on request** (`/prototype`, or "set up the project structure"): build it from my description — create only the feature/domain folders the project needs (a CRM → `contacts`, `deals`, `reminders`; a game → `game/{loop,scenes,entities}`), and omit the rest. Every folder gets a real, used starter file — never empty or `.gitkeep` shells. Wire it to the baseline: types in `src/types`, one core migration with RLS per table, reads through the Supabase client in `src/lib`, routes + placeholder components with loading/empty/error states. Record the layout in `docs/ARCHITECTURE.md`. Keep it a skeleton, not finished features. One PR into `main` with the "For you" block.

## Scale
- Every table grows forever: paginate/limit, index any filtered or joined column, no N+1, handle loading/empty/error/partial states, idempotent writes.

## Migrations (single source of truth)
- Schema exists only as migration files; never change a DB by hand or via a dashboard SQL editor. Merging *is* applying.
- Never edit, rename, or re-timestamp a merged migration — add a new one (fix-forward). A preview branch applies only NEW migration files, so an edited old one silently never runs — that's how databases drift. The first is the immutable baseline; production history always equals the repo.
- Ship schema + the code using it + `src/types` in one PR; every new table includes its RLS.
- Name files `YYYYMMDDHHMMSS_description.sql` in UTC, later than the newest; one schema change in flight at a time.

## Supabase
- Never hand-write `config.toml` — run `npx supabase init` (npx fetches the CLI; needs current Node LTS (20+); never a global `-g` install). Then edit only known keys: `[db.seed]`, plus any declared functions/buckets. **Leave the top-level `project_id` at its `supabase init` default (the working-directory name) — it is a local label, not the remote Project ID.** The parser is strict.
- Edge Functions read secrets from `Deno.env`; never commit a secret.
- `seed.sql` is idempotent. A loginable user needs an `auth.users` row (crypt password, pgcrypto) **with the GoTrue text token columns written as `''`, never left NULL** — at least `confirmation_token`, `recovery_token`, `email_change`, `email_change_token_new`; a NULL in any of them makes login fail with **"Database error querying schema"** (GoTrue scans those columns into non-null strings, so the broken row stays invisible until someone actually logs in) — **plus** a matching `auth.identities` row (provider `'email'`, with a `provider_id`). Make the seed self-healing: after the insert, also `UPDATE` those columns from NULL to `''` for the seeded email, so a branch seeded by an older version repairs itself. Prefer the Admin API for real users. `seed.sql` is NOT a migration — fix it forward by editing it in place; if a preview branch still can't create a loginable user, fall back to `signUp()` then a confirm.
- A preview branch is a full isolated instance (own Auth/Storage) that starts empty — seed what a login/upload test needs.

## Payments (prevent; undo where possible)
- Never store card data — use hosted checkout/tokenization; store only provider IDs.
- Charge only server-side (Edge Function); re-derive the amount; secret key server-only.
- Idempotent everywhere (provider keys + a unique constraint) — no double-charge.
- Wire the provider's undo (refund/void/cancel) and name it in the PR.
- Test mode in dev/previews; live keys prod-only, structurally unable to fire from a preview.
- Webhooks: verify the signature on the raw body, be idempotent, fulfill only after a verified webhook.
- Ship as small flagged PRs; you make the first real charge.

## Memory (three tiers, self-pruning)
- `CLAUDE.md` is your **constitution — read-only**; flag rule gaps to me, never self-edit. Learning goes to memory only.
- One fact per tier, routed by scope: repo `MEMORY.md` = whole-scene facts ("the integration injects PUBLIC_-named vars into previews after step 8.3") · folder `CLAUDE.md` = local wiring ("services/payment.ts re-derives amounts server-side") · agent memory = that agent's own lessons ("flagged a missing index in PR #12; pattern: filtered column"). If a fact fits two tiers, choose the narrowest.
- Start each task by reading memory, record each decision or root cause as you go, correct a lesson when its code is reverted, and prune to stay under ~200 lines.
- When something works, the lesson rides the code PR; when it fails, open a memory-only PR for me to merge — never self-merge.

## Your place + every-PR rules
- Build on a `claude/…` branch, open ONE PR into `main`, and stop there — I review the preview and merge.
- Your job ends at ONE PR into `main`; confirm the base is `main`; never merge or deploy (only I do).
- Your migration runs first on the PR's preview DB; if it fails there, fix the file.
- Irreversible actions (email, charge, state-changing API) need a preview guard + idempotency + a manual-verify flag in the PR.
- **Action care.** Weigh **reversibility** and **blast radius** before acting. Reversible/local (edits on `claude/…`) — proceed. Hard-to-reverse or shared-state (force-push, branch deletion, dependency removal, CI rename, GitHub posts) — confirm first, mid-task counts. Past approval ≠ standing authorization; re-confirm when scope changes. Treat obstacles as root causes — never `--no-verify`, `--force`, or lockfile-delete as a shortcut.
- Read env vars so the same code hits the preview DB on a PR and production on `main`.
- Write the PR description to `.claude/pr-body.md` (committed on the branch) FIRST, then open the PR from its contents — the Stop hook verifies that file locally, not GitHub.
- **Self-check — include this checklist, completed, in `.claude/pr-body.md` and therefore in every PR description (the Stop hook verifies the heading and that every box is ticked):**

## Self-check
- [ ] base = main; exactly one PR
- [ ] ≤ 1 migration, UTC-timestamped latest; new tables have RLS; src/types matches
- [ ] tests/lint/typecheck/e2e green; happy AND unhappy paths exercised
- [ ] scripts still named exactly `lint`, `typecheck`, `test`, and `e2e`
- [ ] key read from `PUBLIC_SUPABASE_URL` and `PUBLIC_SUPABASE_PUBLISHABLE_KEY ?? PUBLIC_SUPABASE_ANON_KEY` in middleware and passed to islands from server props; nothing hardcoded; no secret in code
- [ ] irreversible actions guarded + idempotent + flagged
- [ ] no avoidable debt; memory updated and pruned
- [ ] migrations explained in plain English
- [ ] reviewers ran — `.claude/review/*` verdicts refreshed this PR
- [ ] every subagent dispatched on a model below the orchestrator's — never inherited

- End every PR description with this block, these exact headings:

## For you
**What changed:** one plain-English sentence per change.
**What you do next:** review the preview, then merge — plus any manual env/secret action, stated as a click-path.
**How to roll it back:** the concrete undo for THIS PR.

## Agents, plugins, MCP
- **Roles by capability tier, resolved at dispatch — never by model name.** Your own tier is the model the human picked for this session; you (the orchestrator) own every decision and the final commit, and you dispatch the work down — reviewers one tier **below you**, the `researcher` worker one tier below them. On every dispatch pass the `model` **explicitly** — **omitting it inherits your tier**, silently running subordinate work on the top model. Resolve "below me" from your current in-context lineup (the harness injects it; if a model is unfamiliar, confirm against official docs before ranking it); store no model name anywhere, so a changed lineup — or a tier rename — needs zero edits.
- Agents live in `.claude/agents/` (committed), each with a proactive `description`. Floor = three read-only reviewers (security, code, scale; Read/Grep/Glob only); one read-only `researcher` worker does fan-out reading and drafting and returns text — only you commit. Add more anytime if the user requests; a writer agent should only be able to write drafts, an exception for an agent to be able to open PRs into `main` (never merges) is if the user asks you to give it that permission, if the request is too vague for writing agent, ask them for their intent to see if they want to allow the agent to write drafts or PRs; each agent keeps its own memory. Before every PR you dispatch the three reviewers and record each verdict to `.claude/review/<agent>.md` — the Stop hook requires all three, refreshed that PR.
- **Add/update/delete a part by intent.** On any "add/update/delete the `<agent|skill|hook|workflow|MCP server|rule>` whose job is `<…>`" request: resolve the intent to the exact named file and restate it ("you mean `<name>` at `<path>`"); if it matches two parts or none, ask before touching anything; confirm before any delete; never drop below the three-reviewer floor; name whatever depended on anything removed. One PR into `main`.
- **Skill-first.** Before invoking a project verb (`/prototype`, `/test`, `/verify`, `/revert`), read its `SKILL.md` first — environment-specific constraints aren't in your training.
- Plugins come from the marketplace via `.claude/settings.json`; prefer verified; a community plugin only if I name it.
- MCP servers go in `.mcp.json` (project scope), read-only/observability only; never write/deploy/merge to production.

## Tech debt
- Clean by default. Deliberate debt is a conscious trade with a "Debt I'm leaving" line (I open a `tech-debt` issue); avoidable debt (oversized files, duplication, missing index/state) is a defect — don't ship it.
- Refactors are behaviour-preserving and stand alone (tests green before and after); never inside a feature PR.

## Quality gate
- The sandbox has no DB/secrets — write mocked unit tests, run them before every PR; never fake a DB to pass. A mocked-network Playwright `e2e` suite covers UI/flow regressions unit tests miss and is a required gate.
- Type every mock with the generated row types from `src/types` — schema drift must fail `typecheck`, never pass silently.
- `lint`/`typecheck`/`test`/`e2e` script names are a CI contract (the GitHub workflow jobs call them, and the ruleset requires those jobs) — keep them; if you rename one, update the workflow and tell me to reselect it in the ruleset in the same PR.
- `/health` is a permanent route; never remove or rename it — the uptime and canary workflows depend on it.
- Nothing testable may require a prod-only secret.
- Keep builds reproducible: commit the lockfile; no unpinned `latest` ranges, no installing latest at runtime. Staying current is Dependabot's job — accept its version-bump PRs through the normal flow; track the current Node LTS.
- Small focused PRs; never commit a real secret (`.env.example` placeholders only).
````

3. Review the PR, then merge it (on GitHub: **Pull requests → open it → Merge
   pull request → Confirm** — merging works the same way every time after this).

*Note:* `CLAUDE.md` is the constitution Claude obeys; `MEMORY.md` is the notebook
it learns into.

*Customize it later:* `CLAUDE.md` is read-only — Claude proposes rule changes and
you merge; it never self-edits. To change a rule after setup, see
[Keeping it current → CLAUDE.md rules](06-keeping-it-current.md#claudemd-rules-the-project-constitution)
— the place to go whenever you need to update anything in the pipeline.

## 5. Scaffold a thin baseline
1. In Claude Code, paste this:

```text
Scaffold a MINIMAL Astro + TypeScript app (SSR: output 'server' with the @astrojs/vercel adapter) that builds green and is ready to connect to Supabase and Vercel — nothing project-specific. Create:
- astro.config.mjs with output: 'server' and adapter: vercel().
- src/lib/supabase.ts exporting a createServerClient (from @supabase/ssr) factory that resolves the URL/key server-side from process.env as PUBLIC_SUPABASE_URL and PUBLIC_SUPABASE_PUBLISHABLE_KEY ?? PUBLIC_SUPABASE_ANON_KEY; throw if URL or key is missing. (Production and previews both inject PUBLIC_ names after step 8.3 — no cross-prefix fallback needed.)
- src/middleware.ts building the server client from context.cookies (getAll/setAll) and putting it + the session on context.locals; a client island that needs Supabase receives the public URL + key from server-rendered props, never from import.meta.env.
- A minimal src/pages/ that compiles and renders one page (index.astro). No feature folders yet. If startup throws (e.g. missing Supabase config), render the error message as visible text — a deployment must never show a blank page. No vercel.json (the @astrojs/vercel adapter handles routing; a SPA catch-all rewrite is Vite-SPA-only).
- Mocked unit tests for the server resolver proving it builds a client from PUBLIC_SUPABASE_URL and PUBLIC_SUPABASE_PUBLISHABLE_KEY ?? PUBLIC_SUPABASE_ANON_KEY and shows the readable error when they are absent.
- Run `npx supabase init` for config.toml (do NOT hand-write it). Leave the top-level project_id at its default (the folder name — NOT the remote ref). Set [db.seed] enabled=true, sql_paths=["./seed.sql"].
- supabase/migrations/<UTC>_init.sql that only enables pgcrypto; supabase/seed.sql empty except a comment. (Auth users, storage buckets, and tables come later, when you build those features.)
- Biome (single binary replacing ESLint and Prettier; `biome.json` at the root; `lint` script is `biome check .`) + strict TypeScript + Vitest with one passing test. package.json scripts named exactly `lint`, `typecheck`, and `test` (the step 10 `tests` CI job runs `npm test`).
- A committed package-lock.json; .github/dependabot.yml (weekly npm + github-actions, grouped; no runner field — Dependabot uses GitHub-hosted runners unless the "Dependabot on self-hosted runners" setting is ON); .env.example with the PUBLIC_SUPABASE_* vars; .gitignore ignoring .env*.
- A short CLAUDE.md in src/ (one line: components render, services validate — see the root CLAUDE.md folders rule) and in supabase/ (one line: migrations are append-only and UTC-named — see the root migrations rule). Nothing more — they grow via the memory cycle.
Open a PR into main.
```

2. Review the PR, then merge it into `main`.

*Note:* a thin app that builds green is what Vercel and Supabase connect to
cleanly. It's deliberately bare — auth, storage, and tables arrive later as their
own feature PRs. This first merge happens before the gates exist — it's the
one-time bootstrap (templated projects from step 14 skip this: their gate is up
from the first minute).

## 6. Connect Supabase→GitHub
1. Open the repo's connection (**Organization → Integrations → GitHub
   Connections**): set **Working directory `.`**, turn on **Automatic branching**
   + **Deploy to production**, and make sure **"Supabase changes only" is OFF** —
   with it on, a PR touching no `supabase/` files gets no preview database (its
   **Supabase Preview** check shows *skipped*) and its preview has no
   credentials. Off means every PR spins a preview database that bills Pro
   compute hours until it pauses on inactivity — that's the price of every
   preview working.

*Note:* one empty project becomes production *and* a fresh isolated preview
database per PR; it must start empty because Branching replays your migrations
onto it. "Working directory `.`" is the repo root (it holds `supabase/`).

**✓** the GitHub Connections page shows your repo linked to the project with
branching on. If it says production has migrations the repo lacks, the project
wasn't empty — make a fresh one.

## 7. Import to Vercel
1. vercel.com → **Add New → Project →** import your repo (Astro is auto-detected,
   so there's nothing to set here — the `@astrojs/vercel` adapter produces the SSR
   build); click **Deploy** without adding anything else (the build is green; the
   page errors at runtime until the variables exist — expected).
2. **Settings → Environment Variables →** add `PUBLIC_SUPABASE_URL` and
   `PUBLIC_SUPABASE_PUBLISHABLE_KEY` (the two values you copied), selecting
   **Production** as the only environment for each; then open **Deployments** and
   on the newest one click **⋯ → Redeploy**.
3. **Settings → Environments → Production →** under **Branch Tracking**, make sure
   the branch is **`main`** (the default for new projects).
4. **Settings → Deployment Protection →** make sure **Vercel Authentication** is
   **ON** (Vercel enables it by default on new projects).

*Note:* production is live after step 7.2's redeploy — the app renders with its
Supabase connection. Previews won't have credentials until step 8 connects the
integration.

**↑ Upgrade — commercial / collaborators:** Vercel Hobby is **non-commercial**,
and on a **private repo it refuses deployments from any commit author who isn't
the team owner** — so a second person (or a differently-attributed bot) breaks
deploys. When you take payments, run ads, or add a teammate, move to **Vercel
Pro** (then turn on Rolling Releases + Skew Protection for gradual rollout and
rollback). The flow is unchanged.

## 8. Connect Supabase→Vercel
1. Open **vercel.com/marketplace/supabase** → **Install**; when prompted, connect
   it to this Vercel project and sign in to Supabase.
2. In **Supabase → Organization → Integrations → Vercel**, open the connection
   and make sure your Supabase project is linked to this Vercel project.
3. In **Supabase → Project → Settings → Integrations → Vercel**, click **Manage**
   on your connection and change **Prefix** from `NEXT_PUBLIC_` to `PUBLIC_` →
   **Save** (previews now receive the same `PUBLIC_` names you set in step 7.2 —
   production was already using them).
4. Back in Vercel's **Environment Variables**, delete any **Production**-scoped
   variable whose name contains `SECRET`, `SERVICE_ROLE`, `JWT`, or `POSTGRES` —
   nothing in this stack uses them there. Leave the branch-scoped ones the
   integration creates per PR: they're that preview's own keys, the browser can't
   read them (only the `PUBLIC_` prefix is exposed to Astro client-side code, and
   islands receive values passed from the server rather than reading env directly),
   and they delete themselves when the PR closes.

*Note:* production values are scoped to **Production only** and carry the `PUBLIC_`
names you typed. Each PR's preview gets its **own** values from the integration
when a PR opens or a commit is pushed, injected under the same `PUBLIC_` names
(step 8.3 set the prefix) — `src/middleware.ts` reads `PUBLIC_SUPABASE_URL` and
`PUBLIC_SUPABASE_PUBLISHABLE_KEY ?? PUBLIC_SUPABASE_ANON_KEY` server-side and
passes what the browser needs to islands. Two health signs on any open PR:
its **Supabase Preview** check is green (not *skipped*), and about a minute after
the first build the integration redeploys the preview by itself — that
auto-redeploy is the visible sign the sync ran.

**✓** open one test PR; while it is open, **Vercel → Settings → Environment
Variables** shows `PUBLIC_SUPABASE_*` entries scoped to **Preview** with that
branch's name (created at PR-open or on push, deleted when the PR merges or closes — checking
after a merge always shows nothing), and the preview page renders.

**✗** a preview reads the wrong database, or shows the "missing Supabase config"
text → fix the connection (step 8.2), then push any commit to the PR branch — env sync fires on push and branch creation as well as PR-open; after syncing, the integration redeploys the preview itself.

## 9. Set up agents + self-improvement
1. Paste this to create the review swarm:

```text
Create three review agents plus one worker in .claude/agents/ (committed), tools locked to Read, Grep, Glob only — no write, no bash. Each reviewer gets a proactive `description` so I dispatch it before opening any PR. The agents are **model-agnostic** — no model is named in their files; the orchestrator dispatches each reviewer one tier **below itself**, passing the `model` explicitly at dispatch (omitting it inherits the orchestrator's tier):
1. security-reviewer — description: "Use before every PR to check security." Flags: a new table without RLS, any secret or service-role key referenced in client code, any user input not validated in src/services/, auth/money/PII/upload changes missing a stated abuse case.
2. code-reviewer — description: "Use before every PR to check code quality." Flags: duplicated logic, files over ~200 lines or with mixed responsibilities, components doing data access directly, missing loading/empty/error/unauthorized states, and any changed src/services file with no sibling *.test.ts change in the same diff.
3. scale-reviewer — description: "Use before every PR to check scale." Flags: queries without pagination/limits, filtered or joined columns without an index, N+1 query patterns, non-idempotent writes.
4. researcher — description: "Use to do fan-out reading, search, and drafting for the orchestrator." The orchestrator dispatches it one tier below the reviewers; reads, searches, and drafts and returns text; never commits — the orchestrator reviews, fixes, and commits its output.
Each agent keeps its own memory file. Before opening any PR, the orchestrator dispatches the three reviewers and records each verdict to .claude/review/<agent>.md. Open a PR into main.
```

2. Paste this to add the self-improvement hooks:

```text
Add two hooks to .claude/settings.json (committed). Open a PR into main.
1. SessionStart: if node_modules is missing, run `npm install`; then output the repo-root MEMORY.md and the current git branch so they load into context.
2. Stop + SubagentStop: a small script that blocks task completion (exit code 2 with a reason, per the hook contract) UNLESS one of these holds:
   - the branch has no commits ahead of main and a clean working tree (a Q&A session — nothing to police), or
   - the committed file .claude/pr-body.md contains a "## Self-check" heading with every checkbox ticked ("- [x]"), AND the three reviewer verdicts (.claude/review/security-reviewer.md, code-reviewer.md, scale-reviewer.md) were each refreshed this task, AND a memory file (MEMORY.md, a folder CLAUDE.md, or an agent memory) was modified this task OR pr-body.md states "no new lesson".
   Also, whenever work exists, fail if any of .claude/agents/{security,code,scale}-reviewer.md is missing — the three-reviewer floor can never be deleted away.
   The PR description is created FROM .claude/pr-body.md — write the file first, then open the PR with its contents. Verify everything with git and the filesystem only — never call gh or the network (cloud sandboxes may lack both; a hook that can't read its evidence false-blocks forever). Block only at task end, never on file writes.
```

3. Review and merge each PR.

*Note:* the orchestrator **dispatches** each reviewer a tier below itself and the
`researcher` worker a tier below them — passing the model explicitly each time,
since omitting it inherits the orchestrator's tier — reviews and fixes their
output, and is the only one that commits; it records each reviewer's verdict to
`.claude/review/` so the Stop hook can confirm the review ran. The hooks make
memory automatic: load `MEMORY.md` at session start, and don't let a task end
until the self-check ran, the reviewers ran, and a lesson was recorded.

*Customize it later:* to change the review swarm or the hooks, see
[Keeping it current → Reviewer agents](06-keeping-it-current.md#reviewer-agents--the-researcher-worker)
and [→ Self-improvement hooks](06-keeping-it-current.md#self-improvement-hooks) —
Claude names the exact target and confirms before deleting, and never drops below
the three reviewers.

**↑ Upgrade — give Claude eyes (read-only):** one prompt — `Add the github,
supabase, and vercel MCP servers to .mcp.json (project scope, committed),
read-only/observability ONLY: scope the Supabase server to this project, set its
read-only flag, never write/deploy/merge. Open a PR into main.` — then authorize
each in-browser. Now Claude can read logs, schema, and issues to debug, while
still unable to change production. *Customize it later:* see
[Keeping it current → MCP servers](06-keeping-it-current.md#mcp-servers-read-only-eyes)
— read-only/observability only.

## 10. Add the repo's workflows
1. Paste this for the CI gate:

```text
Create .github/workflows/ci.yml: on every pull_request AND on push to main, three jobs named exactly "tests", "lint", and "typecheck"; each runs the current major versions of actions/checkout and actions/setup-node with node-version "lts/*" (always the current LTS — never hardcode a number) and cache npm, then `npm ci`, then `npm test` / `npm run lint` / `npm run typecheck` respectively; a job fails if its command fails. The tests job runs with Vitest coverage (text-summary reporter) and appends the summary to the GitHub job summary — coverage is a signal for the human at review time, NEVER a threshold gate (thresholds breed test theater). Open a PR into main.
```

2. In GitHub **Settings → General**, make sure **"Automatically delete head
   branches" is OFF** and enable **"Allow auto-merge"**; then in **Settings →
   Advanced Security**, turn **Dependabot security updates ON** (CVE patches
   arrive as PRs through the normal gate, not just weekly version bumps). Also
   confirm **"Dependabot on self-hosted runners" is OFF** — if it is ON with no
   self-hosted runners, Dependabot jobs queue indefinitely and never run. Paste
   this so Dependabot patch updates merge automatically once CI is green:

```text
Create .github/workflows/dependabot-auto-merge.yml: triggered on pull_request_target (so GITHUB_TOKEN has write access for Dependabot PRs), permissions contents: write and pull-requests: write. One job that runs only when github.actor == 'dependabot[bot]': step 1 — dependabot/fetch-metadata@v2 with id "meta" and github-token from GITHUB_TOKEN; step 2 — if meta.outputs.update-type is 'version-update:semver-patch', run `gh pr merge --auto --squash "$PR_URL"` with env GH_TOKEN from GITHUB_TOKEN and PR_URL from github.event.pull_request.html_url. Open a PR into main.
```

3. Paste this for branch cleanup:

```text
Create .github/workflows/branch-cleanup.yml: runs on a daily schedule, with permissions contents: write, using the built-in GITHUB_TOKEN (no third-party action). Delete only branches with NO commits for 7+ days AND no open PR — never delete recently-active branches even if merged, and NEVER main (hard-exclude it by name). Open a PR into main.
```

4. Paste this for the production uptime monitor (zero secrets — production isn't
   behind Vercel Authentication):

```text
Add a permanent GET /health route that does one cheap Supabase round-trip needing no app tables (e.g. auth.getSession) and renders/returns "ok" on success. Then create .github/workflows/uptime.yml: on a 30-minute schedule, with permissions issues: write, read the repo Actions variable PRODUCTION_URL; if it is unset, exit successfully without doing anything (so a fresh templated repo stays green); otherwise fetch ${PRODUCTION_URL}/health and, unless it returns ok, open (or update, never duplicate) a GitHub issue titled "uptime: /health failing". Open a PR into main.
```

5. Point the uptime monitor at production so it starts watching — the workflow
   you just added in step 10.4 ships **dormant** and no-ops until this variable
   exists (that's also why a fresh templated repo stays green). `PRODUCTION_URL` is
   your **Vercel** production URL — the public address of your deployed app (its
   `*.vercel.app` domain or your custom domain, the one **Deployments → Visit**
   opens), **not** the Supabase project URL. `/health` is a route *on your app*
   that makes the Supabase call server-side, so the monitor must hit the app: paste
   the Supabase URL by mistake and `…supabase.co/health` answers **"No API key
   found in request"** (that's Supabase's API gateway, not your app) and the
   monitor files a false outage. Set it in GitHub: **Settings → Secrets and
   variables → Actions → Variables → New repository variable** → name
   `PRODUCTION_URL`, value that Vercel URL.
6. Paste this for the E2E gate (your cloud env must already allow
   `cdn.playwright.dev` — step 2.3):

```text
Create a mocked-network Playwright E2E suite plus its CI gate. Add @playwright/test as a devDependency and an "e2e" script ("playwright test"). playwright.config.ts: chromium only; a webServer that builds the app with stub Supabase env set inline (a stub PUBLIC_SUPABASE_URL and publishable key, so the bundle has config but reaches nothing real) and serves the preview on a fixed port used as baseURL; retries 2 in CI / 0 locally; trace on-first-retry. e2e/_mocks.ts intercepts every request to the stub host with deterministic defaults (no session, empty lists) so the suite is offline. e2e/smoke.spec.ts covers a few network-light flows with role/label selectors — the landing page renders, a client-side validation error shows with no network, and a logged-out visit to a gated route redirects to login. .github/workflows/e2e.yml: a job named exactly "e2e" running npm ci, `npx playwright install --with-deps chromium`, then the suite, uploading the trace artifact on failure. Add playwright-report/ and test-results/ to .gitignore and exclude them from Biome's analysis in biome.json. Run it green in the sandbox before opening the PR. Open a PR into main.
```

7. Review and merge each PR.

*Note:* the `tests`, `lint`, `typecheck`, and `e2e` jobs are the merge gate from
day one — they run on every PR and are what the ruleset (step 11) will require;
they also run on pushes to `main` so the step 11 release-gate upgrade can read
them. The `e2e` job is **mocked-network** — it builds the app against a stub
Supabase it never reaches, so it's deterministic and needs no preview database or
secret; keep it mocked, because a required check pointed at a live preview would
flake (the human's preview check and the optional seeded-preview run below are
where real data is exercised). The uptime monitor is the eye that stays open
after a merge: production breaks, an issue appears — paste it to Claude.
("Monitor" watches production on a clock and files issues; the word **canary** is
reserved for the optional PR check below — they share only the `/health` route.)
Auto-delete stays **OFF** and cleanup is inactivity-only because deleting a branch
a live Claude Code session is still working on breaks the session — a week of
silence is the only safe signal a branch is abandoned. `main` is never touched;
Supabase preview branches clean themselves.

*Customize it later:* see
[Keeping it current → Workflows](06-keeping-it-current.md#workflows-ci-and-the-gates)
— renaming a required job means reselecting it in the ruleset (step 11).

**↑ Upgrade — independent review on every PR:** the in-build swarm reviews
Claude's own work; this adds a *separate* reviewer on the PR itself. Get an API
key at console.anthropic.com and add it as the `ANTHROPIC_API_KEY` repo secret
(GitHub → Settings → Secrets and variables → Actions), then paste:

```text
Create .github/workflows/claude-review.yml: on pull_request [opened, synchronize, reopened], run anthropics/claude-code-action@v1 with permissions contents: read and pull-requests: write ONLY (comment only — never approve, push, or merge), ANTHROPIC_API_KEY from secrets, a pinned model, and tools restricted to posting inline + summary comments (no edits, no git push). Tell it to flag, against CLAUDE.md: missing RLS on new tables, any secret key in client code, unvalidated server inputs, unsafe migrations (editing a merged migration / irreversible changes), missing loading/empty/error/unauthorized states, and duplicated or oversized code. Keep it advisory — do NOT make it a required check. Open a PR into main.
```

Its value past the in-build swarm is independence — it reviews on a model the
orchestrator can't influence, so it isn't a third copy of the same pass. It
comments on every PR (~$1–2 each); it can never merge. Promote it to a required
check only once you trust it.

**↑ Upgrade — extend the canary to PR previews:** previews sit behind Vercel
Authentication, so this one needs a token: in **Vercel → Settings → Deployment
Protection**, generate a **Protection Bypass for Automation** secret and add it
as the `VERCEL_AUTOMATION_BYPASS_SECRET` repo secret, then one prompt: `Create
.github/workflows/canary.yml: on deployment_status where state == success and the
environment is Preview, fetch {deployment_status.target_url}/health with header
"x-vercel-protection-bypass: ${{ secrets.VERCEL_AUTOMATION_BYPASS_SECRET }}"; fail
unless it returns ok. Name the job's check exactly "canary". Open a PR into main.`
Then add `canary` to the required checks in the next step — now a preview that
can't reach its database *blocks the merge* instead of waiting for your eye. Once
it runs, one more prompt can extend it past `/health` to two or three seeded read
endpoints — cheap integration tests against a real database on every PR.

**↑ Upgrade — drive the seeded preview with Playwright (optional, never the
required gate):** the mandatory `e2e` job is mocked; this one exercises a *real*
seeded preview end to end, reusing the canary's `VERCEL_AUTOMATION_BYPASS_SECRET`.
One prompt: `Add a second, optional Playwright project that points baseURL at a
preview URL passed by env, sends the Vercel protection-bypass header on every
request, logs in as the seeded demo user, and walks one real seeded flow (open
the seeded course, complete a lesson). Run it only when the preview-URL env is
set; never inside the mocked e2e job. Open a PR into main.` Keep it out of the
required checks — it needs the token and a live preview and is flakier than the
mocked gate, and it depends on a demo user being seeded (Part 3's auth note).

**↑ Upgrade — test your Edge Functions (the day the first one ships):** the
Vitest gate covers `src/`, but the Deno Edge Functions hold the most fragile
logic (AI calls, parsing, payments). Test them **in the same `tests` job, without
Deno**: one prompt — `Extract the pure logic of each Edge Function into helper
modules (a standalone, behavior-preserving refactor PR first if functions already
exist), and test those helpers with Vitest. Alias the functions' Deno npm:
specifiers (e.g. npm:fflate, npm:unpdf) to the matching npm packages in your
Vitest config (or `astro.config.mjs`'s `vite` key) so Vitest runs the logic
without a Deno runtime — keep the alias versions in lockstep with the npm:
strings. Open a PR into main.` No separate CI job, no setup-deno, no sandbox
exception — it rides the existing `tests` gate.
(Real `deno test` in the sandbox is now reachable by allowlisting `deno.land` in
step 2.3, but it only adds coverage of the thin handler glue the vitest-aliased
helpers already exercise — not worth the extra toolchain.)

**↑ Upgrade — faster CI with Depot runners:** Depot replaces GitHub's default runners with no workflow rewrite — the entire integration is one `runs-on` label change per job. Up to 3× faster build execution and 10× faster cache operations (~1 GB/s vs GitHub's ~145 MB/s), with sub-5-second runner startup.

1. [depot.dev](https://depot.dev) → **Sign up**; install the Depot GitHub App for your repository.
2. Paste:

```text
Update .github/workflows/ci.yml and .github/workflows/e2e.yml: change every `runs-on: ubuntu-latest` to `runs-on: depot-ubuntu-latest`. No other changes. Open a PR into main.
```

3. Review and merge the PR.

*Note:* the only change is the `runs-on` label — no steps, secrets, or workflow logic change. To roll back, revert both files to `ubuntu-latest`. Check [depot.dev/pricing](https://depot.dev/pricing) before enabling on a private repository. Verified Jun 2026 (depot.dev/docs/github-actions/overview).

## 11. Protect `main`
1. **GitHub → Settings → Rules → Rulesets → New branch ruleset.** (A templated
   project from step 14 instead clicks **Import a ruleset** and selects the
   committed JSON — done, skip to the ✓.)
2. **Enforcement = Active**; **Target branches → include `main`**.
3. **Require a pull request** → **Required approvals = 1**.
4. **Require status checks to pass** + **Require branches to be up to date before
   merging** → click **Add checks**, search each name, and tick it under
   **Suggestions**: `tests`, `lint`, `typecheck`, and `e2e` (each attributed to
   GitHub Actions), **Supabase Preview** (Supabase), and **Vercel** (Vercel) —
   plus **`canary`** if you added it. Skip **Vercel Preview Comments** (it tracks
   the PR comment, not the deploy) and the typed **Add … Any source** row (that's
   GitHub offering your raw text as an unattributed check). A check appears under
   Suggestions only after it has reported on a PR at least once — if one is
   missing, open a throwaway PR so it reports, then refresh.
5. **Require conversation resolution** + **linear history**.
6. **Block force pushes** + **Restrict deletions**.
7. **Bypass list** → **Add bypass** → **Integration** → search and select
   **Dependabot** → **Pull requests only**; then **Create**. (This lets the
   auto-merge workflow from step 10.2 skip the approval gate for Dependabot patch
   PRs — CI still runs and must pass.)

*Note:* this is the human gate — Claude opens PRs but can't approve its own. It's
last because it needs the checks the earlier steps created: `tests`/`lint`/
`typecheck`/`e2e` come from step 10's workflows, **Supabase Preview** from step
3's branching, **Vercel** from step 7's import. The Dependabot bypass waives only
the approval requirement for patch updates — CI still runs on every Dependabot PR
and must pass before auto-merge fires.

**✓** a PR with a failing check won't merge; trying to merge without an approval
is blocked. *Two gotchas that quietly un-gate it:* on a **private** repo the
ruleset binds only on GitHub **Pro/Team** (otherwise it's advisory — an early or
direct-to-`main` push slips through; see the teammate upgrade below), and a check
you never ticked (because it hadn't reported when you built the ruleset) isn't
required — re-open the ruleset and add **Supabase Preview**/**Vercel** once they
have each reported, or merges aren't gated on them.

**↑ Upgrade — a second gate after merge (Vercel Deployment Checks):** the ruleset
gates the *merge*; this gates the *release*. After a merge, Vercel builds
production but holds it off your domains until the GitHub checks you select pass
on that commit — then it goes live on its own. In **Vercel → Settings →
Environments → Production**, confirm automatic aliasing is on; then in **Settings
→ Deployment Checks**, click **Add Checks**, choose **GitHub** as the provider,
and select `tests`, `lint`, `typecheck`, and `e2e` (and `canary` if you added it —
pick names only after each has run at least once, or the list is empty). A held
deployment can be released by hand with **Force Promote** on its deployment page.
Renaming a workflow job silently orphans its Deployment Check — reselect after any
rename.

**↑ Upgrade — add a teammate:** three invites, no flow change — in the GitHub
repo, **Settings → Collaborators → Add people**; in your Vercel team (Pro),
**Members → Invite** — this one is what lets their work deploy: GitHub access
alone builds nothing, because Vercel builds a private repo's commits only for team
members, and linear history makes every squashed PR commit *authored by the PR's
author* (so on Hobby even a PR you merge yourself is refused if they wrote it); in
your Supabase organization, **Team → Invite**. The gate you just built does the
rest: the required approval now comes from a human who isn't the PR's author, and
on a private repo GitHub Pro/Team is what makes the ruleset enforce.

## 12. Install the command skills
Paste each block and merge its PR.

**/prototype — lay out a project:**

```text
Create .claude/skills/prototype/SKILL.md with YAML frontmatter (name: prototype; description: "Lay out a new project's structure from a plain-English description. Use when asked to prototype, scaffold features, or set up project structure.") so /prototype <description> builds a baseline: in plan mode, lay out the screens + core entities and show me first; then build a navigable skeleton per CLAUDE.md (routes, placeholder components, loading/empty/error states); define types in src/types + ONE migration for the core tables (RLS + policies); wire reads through the Supabase client in src/lib; keep it a skeleton, not finished features; open ONE PR into main with the "For you" block.
```

**/test — design reusable tests:**

```text
Create .claude/skills/test/SKILL.md with YAML frontmatter (name: test; description: "Design durable mocked tests for a feature or file. Use when asked to test something or when a change lacks coverage.") so /test <feature or file> designs durable tests: pick the smallest meaningful unit; write mocked unit tests (no real DB/secrets) for the happy path AND the unhappy paths (empty, invalid, unauthorized, duplicate/idempotent write); type every mock with the generated row types from src/types so schema drift fails typecheck instead of passing silently; name files <unit>.test.ts beside the code so the CI test gate reruns them on every PR, and name each test after the path it guards ("rejects unauthorized", "idempotent on resubmit") so unhappy-path coverage is greppable; follow the goal-driven rule (failing test first, then pass); never weaken a test to make it green. Open a PR into main listing what each test guards.
```

**/verify — check a build:**

```text
Create .claude/skills/verify/SKILL.md with YAML frontmatter (name: verify; description: "Walk the human through checking the current PR's preview. Use when a PR is ready for review or when asked to verify.") that, for the current PR: summarizes what changed, runs the three reviewers, confirms the preview is on its own branch DB by checking the PR's "Supabase Preview" check is green (not skipped), that /health returns ok, and that the preview renders the app rather than the "failed to start / missing Supabase config" text — if any fail, route me to step 8's ✗ remedy (fix the connection, step 8.2, then push any commit to the PR branch to retrigger env sync) — exercises the happy AND unhappy paths, and returns a plain-English what-to-click / what-should-happen / what-means-broken. Read-only. Open a PR into main.
```

**/revert — undo safely:**

```text
Create .claude/skills/revert/SKILL.md with YAML frontmatter (name: revert; description: "Route the human to the right undo for a bad change. Use when something broke after a merge or when asked to revert.") that determines whether the bad change was code / schema / data, then routes me: code → Vercel Instant Rollback or a drafted GitHub Revert PR; schema → a drafted reversing-migration PR; data → guide PITR; money → provider refund/void/cancel. You draft and guide, never merge or touch main. Open a PR into main.
```

*Note:* each turns a recurring job into one verb (`/name`), and Claude can also
invoke it on its own when relevant.

*Customize it later:* see
[Keeping it current → Command skills](06-keeping-it-current.md#command-skills) —
each is invoked as `/name`.

## 13. Lay out your project structure
1. In Claude Code, run `/prototype <what it is · who uses it · core entities ·
   scope>`.
2. Approve the plan it shows you.
3. It opens one PR; review the preview, then merge.

*Note:* your first real gated change — the structure goes through the full gate,
built from your description.

**↑ Upgrade — let maintenance run itself:** the workaround table at the end of
this guide asks you to re-check it every few months. A **Routine** (Claude Code
research preview) does that on a schedule: at claude.ai/code, open **Routines →
New routine**, pick this repo, set it **monthly**, and paste:

```text
Re-verify each item below against the platforms' CURRENT official documentation, then check this repo's code for the workaround:
1. Auth-seed SQL + signUp() fallback — retirable when Admin API user creation works on Supabase preview branches.
2. The SessionStart hook loading the committed MEMORY.md — retirable when Claude Code's auto memory syncs across cloud environments.
If — and only if — an item's retire condition is met, open ONE PR into main removing that workaround and every part of the repo depending on it. ALWAYS end with a dated report: per item, STILL NEEDED or RETIRABLE, plus the documentation URL you read and the sentence that decides it. Never touch main directly.
```

A routine can only push to `claude/…` branches and open PRs — your gate still
reviews everything it proposes. Caveats: research preview (may change) and its
runs share your plan's usage quota.

## 14. Make it a template (every next project becomes a recipe)
The committed files — constitution, scaffold, agents, hooks, workflows, skills —
are the reusable half of this pipeline; the dashboards are the per-project half.
Capture the first half once:

1. Build the template repo (one-time): repeat steps 1, 4, 5, 9, 10, and 12 in a
   fresh repo (e.g. `pipeline-template`) — no Supabase, Vercel, or ruleset needed
   there, so it's just the prompts and merges. **Never template a finished app**:
   migrations, feature code, and MEMORY.md are project-specific and would poison
   every copy. Add one line to its CLAUDE.md: "This repo is a mold — nothing
   project-specific may ever merge here." Then close with the audit prompt:

```text
Audit this repo against the baseline manifest and report — fix nothing: root CLAUDE.md + folder CLAUDE.mds; EMPTY MEMORY.md; three reviewer agents plus the `researcher` worker, each with memory sidecars and no model named in their files; the Stop/SessionStart hooks; ci.yml (tests/lint/typecheck), branch-cleanup.yml, uptime.yml, e2e.yml (job `e2e`); playwright.config.ts + the e2e/ suite + the `e2e` script; dependabot.yml, dependabot-auto-merge.yml; the four skills; the scaffold with the server-side PUBLIC_ resolver in src/middleware.ts, /health, and typed resolver tests (no vercel.json); .github/main-ruleset.json; only the pgcrypto init migration. Flag anything missing, anything extra, and anything project-specific.
```
2. In the template repo: **Settings → General → Template repository → ON**.
3. Export your working project's ruleset once — **Settings → Rules → Rulesets →
   open it → ⋯ → Export** — and paste one prompt in the template repo: `Commit
   this ruleset JSON at .github/main-ruleset.json so new projects import it
   instead of re-clicking the ruleset UI. Open a PR into main.`
4. **Every next project:** on the template repo, click **Use this template →
   Create a new repository** → grant the Claude GitHub App access to it
   (github.com → **Settings → Applications → Claude → Repository access** → add
   the new repo — step 2.1 granted only-selected repos, so each new one must be
   added) → redo step 10.2's settings (auto-delete OFF, Allow auto-merge ON, Dependabot
   security updates ON, self-hosted runners OFF — templates copy files, never settings) → set the new cloud env's
   network per step 2.3 (Custom + the default-package-managers box +
   `cdn.playwright.dev`) → do step 3 (new Supabase project) and step 7 (new Vercel
   project) for it → **Settings → Rules → Rulesets → Import a ruleset** → select
   the committed JSON → paste the bootstrap prompt below → merge its PR (fully
   gated — every check already exists) → set `PRODUCTION_URL` (step 10.5) → run
   `/prototype`.

```text
Bootstrap this templated repo for a new project: empty MEMORY.md and the agent .memory.md sidecars, reset docs/ARCHITECTURE.md to a stub, set the app title and the config.toml project_id label to this repo's name. Touch nothing else. Open a PR into main.
```

*Note:* a template copies **files, not settings** — that's why Supabase, Vercel,
and the ruleset are redone per project (the JSON import collapses the ruleset to
one click) and why the uptime workflow ships dormant until `PRODUCTION_URL` is
set. Required checks imported before they've ever reported simply hold the merge
until each reports on the bootstrap PR — the gate is up from the first minute, so
a templated project never has the un-gated bootstrap window the first project had.

**✓** "Use this template" on a fresh repo + the recipe above ends with the
bootstrap PR merged through a fully green, fully gated pipeline in about 30
minutes.

---

Next: [Part 3 — Ship a feature (daily) →](03-ship-a-feature-daily.md)
