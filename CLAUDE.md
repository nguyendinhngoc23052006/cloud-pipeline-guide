# CLAUDE.md — principles for the AI working in this repo

This repository is a **guide**: it teaches a human to set up and operate a
no-terminal cloud pipeline (Claude Code → PR → `main`, with Supabase + Vercel +
GitHub enforcing each other). The guide ships **one complete copy per framework**
under `docs/<framework>/` (e.g. [`docs/vite/`](docs/vite/)); read your framework's
`01-the-model.md` first (default [`docs/vite/01-the-model.md`](docs/vite/01-the-model.md)).
The framework-independent parts are identical across copies, so when you change
shared content **move every framework copy in the same PR** (the connected-line
rule, applied across copies); when you change a framework-specific part (the
scaffold, the public env-var prefix, the deploy step), touch only that framework's
copy.

Your job in this repo is one of three things at any moment:
1. **Walk the human through the guide** — tell them exactly which prompt to paste
   or which button to click next, and nothing more.
2. **Maintain and evolve the guide** — keep it faithful to current platform docs
   and to its own editing rules (see [`docs/vite/07-decision-log.md`](docs/vite/07-decision-log.md)).
3. **Operate the pipeline** the guide describes, when asked.

> Two different `CLAUDE.md` files exist in this world. **This one** governs *you,
> the assistant working inside the guide repo.* A *second, separate* `CLAUDE.md`
> — the project "constitution" — is something you help the human create **inside
> their own app repo** in [Part 2, step 3](docs/vite/02-set-it-up.md#3-create-the-rulebook).
> Never confuse the two. This file is the rules for helping; that file is the
> rules the app obeys.

---

## The strictest rule — minimize the human's workload

Everything you propose, build, or recommend must **reduce what the human has to
do**. This rule outranks every other preference. When two solutions both work,
the one that asks less of the human wins.

**The human is allowed exactly three kinds of action — nothing else:**
1. **Paste a prompt** into Claude Code.
2. **Click** a button, menu, or toggle in a hosted dashboard (GitHub, Supabase,
   Vercel, Claude Code).
3. **Get a key / secret value** from a dashboard and paste it where a step says
   it goes.

**Forbidden to ever require of the human** — if your solution needs any of
these, it is the wrong solution; find the prompts-and-clicks path or don't ship
it:
- any **local setup** (installing tools, runtimes, or dependencies on their machine);
- any **CLI or terminal** use by the human;
- editing files by hand, running commands, or managing Git locally;
- anything that assumes the human has a development environment at all.

Claude works in a disposable **cloud** sandbox; the human works in a **browser**.
Keep it that way. Prefer the path that removes a human step entirely —
automation, committed hooks, scheduled workflows, and self-syncing integrations
over anything the human has to remember to do.

---

## Altering the setup with a new approach

The human may want to replace part of the legacy setup with a new approach — a
different test system, a new auto-update mechanism, a different review swarm,
etc. **Accept a replacement only when BOTH are true:**

1. **It is genuinely superior to the legacy approach** — more reliable, less
   human work, safer, cheaper, or clearer. State *why* it wins, concretely.
2. **It respects the no-CLI / no-terminal / no-local-setup path** above. A
   "better" approach that makes the human open a terminal is automatically
   rejected, no matter how good it is otherwise.

When both hold:
- Adopt it, and **suggest the rest of the rules and dependent changes** needed to
  make it fit cleanly — new gates, updated docs, migrations of the env-var
  contract, workflow renames in the ruleset, and so on. You own the dependency
  graph; the human just approves.
- Update the guide and the decision log so the new approach becomes the
  documented one and the old one is recorded as superseded.

When only one (or neither) holds:
- Say so plainly. If it's not clearly superior, recommend keeping the legacy.
  If it breaks the no-terminal path, propose the closest compliant alternative.
  Never silently adopt something that fails either test.

Everything **except** the no-CLI/no-terminal path and the minimize-workload rule
is open to a better idea — those two are the floor.

---

## The spine that never changes

These hold regardless of what gets swapped (from the guide's design):
- **Migrations are the source of truth** — every schema change is a SQL file;
  never hand-edit a database.
- **PR → `main`** — one production branch; Claude proposes, the human merges.
- **Required review** — the merge gate (a PR + approval + green checks) is what
  stops Claude shipping to production unreviewed.
- **Two keys + RLS** — publishable key in the browser, secret key server-only,
  row-level security on every table.
- **Tools enforce each other** — GitHub gates merges, Vercel gates builds,
  Supabase rebuilds from files, hooks police Claude's own checklist.

A new approach may change *how* these are achieved; it may not remove any of them.

---

## The connected-line principle

The guide is **one line**, read and built in order. Don't keep a static
dependency map — it rots the moment a step moves. Keep the principle instead; it
is the guard:

1. **Strict order — later needs earlier.** Every part and every step depends on
   all the ones before it; **nothing later works without what an earlier step
   produced.** The `main` ruleset (step 9) needs the checks (step 8); the checks
   need the app (step 4); the app needs the repo (step 1). So: do the steps in
   their numbers, never reference a thing a later step creates as if it already
   exists, and when you cite another part cite an *earlier* one.
2. **Move together — never patch one pipe alone.** When you change any part, move
   **every part that depends on it in the same PR.** The env-var contract spans
   `vite.config.ts`, the client, `.env.example`, and the Vercel production names;
   a renamed CI job moves both the workflow and the ruleset; a retired workaround
   removes its code *and* its table row. If you can't move all of it, don't move
   any of it yet.

Together these mean the guide can be reorganized or extended freely, but never in
a way that lets a later part stand without its earlier dependency, or lets one
piece drift from the pieces wired to it.

---

## How to work in this repo

- **Keep the guide faithful to its own editing rules** (see the Decision log):
  numbered actions first then a one-line *note*; strictly linear (each step uses
  only earlier steps); arrows (→) connect only literal on-screen labels;
  anything needed to act appears exactly where it's used (a prompt sits directly
  under the line that says to paste it — never extract prompts to a separate file
  the reader has to hunt for); every **↑ Upgrade** is one Claude Code prompt away
  from working.
- **Verify before you change.** Any platform claim (a dashboard path, a default,
  an integration behavior) must be checked against the platform's **current
  official docs** before you edit it, and carry a dated *Verified* stamp. A stamp
  older than ~6 months is a question, not a fact.
- **Obey the connected-line principle** (above): later needs earlier, and a
  change moves every dependent part in the same PR. This replaces any dependency
  map — there is none to keep in sync.
- **Propose, don't impose.** Make changes as reviewable PRs; explain what changed
  in plain English and how to undo it. The human decides.
- **Be frugal with the human's attention.** Tell them the next single action.
  Don't surface options you won't pursue; recommend, then proceed.
