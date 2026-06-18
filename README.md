# Cloud Pipeline Guide

A complete, **no-terminal** way to ship a web app: in Claude Code you describe a
feature; it writes the code on a throwaway `claude/…` branch and opens a **pull
request** into `main`; that PR gets its own live preview (its own database + URL);
you review and merge. On merge, Supabase migrates the production database and
Vercel deploys.

This repository is the **guide** for setting that up and running it day to day —
not the app itself. Everything the guide tells you to build lives **inside your
own app repo**, created by pasting prompts into Claude Code. You never open a
terminal.

## Who this is for

A human who can paste a prompt, click a button, and copy a key from a dashboard —
and wants to do nothing else. No local setup, no CLI, no command line, ever. That
constraint is the whole point; see [`CLAUDE.md`](CLAUDE.md).

## Choose your framework

This guide ships **one complete copy per framework** — pick yours and follow it
end to end; you never need another framework's copy. Every copy has the same seven
parts in the same order; only the framework-specific pieces (the scaffold, the
public env-var prefix, the deploy specifics) differ.

- **[Vite + React](docs/vite/01-the-model.md)** — apps behind a login (no SEO
  need). The default; choose it if you're unsure.
- **Next.js**, **Astro**, **SvelteKit** — guides being added under `docs/` for
  SEO-driven and full-stack-framework apps.

## How to use this repo

1. Read **Part 1 — The model** once.
2. Do **Part 2 — Set it up** once, top to bottom.
3. Then live in **Part 3 — Ship a feature (daily)**.

In every step the **numbered lines are the actions**; the italic *note* under
them is the one thing worth knowing. **↑ Upgrade** notes are optional add-ons you
can do later.

If you open this repo in Claude Code, the assistant reads [`CLAUDE.md`](CLAUDE.md)
and will walk you through the next single action and help you maintain the guide.

## Contents

Each framework's guide has the same seven parts (paths below shown for Vite — swap
`vite/` for your framework's folder):

| File | What it guides you to do | Go here when |
|---|---|---|
| [`docs/vite/01-the-model.md`](docs/vite/01-the-model.md) | Understand the pipeline and its five rules | first, before anything |
| [`docs/vite/02-set-it-up.md`](docs/vite/02-set-it-up.md) | Wire the four tools together in 12 steps | building it the first time |
| [`docs/vite/03-ship-a-feature-daily.md`](docs/vite/03-ship-a-feature-daily.md) | Build and ship a feature through a PR | every working day |
| [`docs/vite/04-when-something-breaks.md`](docs/vite/04-when-something-breaks.md) | Roll back code, schema, data, or a payment | something broke after a merge |
| [`docs/vite/05-honest-limits.md`](docs/vite/05-honest-limits.md) | Know what this can and can't do | setting expectations |
| [`docs/vite/06-keeping-it-current.md`](docs/vite/06-keeping-it-current.md) | Add / update / delete / refresh any part | changing the pipeline later |
| [`docs/vite/07-decision-log.md`](docs/vite/07-decision-log.md) | See why each choice was made (and rejected) | questioning a design choice |
| [`CLAUDE.md`](CLAUDE.md) | (for the AI) the principles it follows here | — |

## Read and build in order — each part needs the ones before it

The pipeline is **one connected line**: nothing in a later part works without what
an earlier part produced (the merge gate needs the checks; the checks need the
app; the app needs the repo). So do Part 2's steps in their numbers, and when the
guide changes, every dependent piece moves in the same change. There is no
separate dependency map to keep in sync — that ordering *is* the rule. The AI
enforces it; see [the connected-line principle in `CLAUDE.md`](CLAUDE.md#the-connected-line-principle).

## The plans you need

- **Supabase Pro** (Branching needs it) and **Claude Code Pro+** (cloud sessions)
  are required.
- **GitHub** and **Vercel** start free (see the upgrade notes for when to move up).

## The one rule above all others

Everything must **minimize the human's workload**. Pasting prompts, clicking
buttons, and getting keys are fine; local setup and the command line are never
required. If you want to swap in a new approach (a different test system, a new
auto-update mechanism), it's welcome — *as long as it is superior to what it
replaces and still needs no terminal*. The full statement is in
[`CLAUDE.md`](CLAUDE.md).
