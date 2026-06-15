# Part 3 — Ship a feature (daily)

> **This part guides you to:** build a feature by describing it, then review its
> preview and merge. Needs the whole of Part 2 in place. When a merge goes wrong,
> Part 4 takes over.

> This is where you live after setup. Two slots in, review the preview, merge.

**Build:** in Claude Code (from `main`), describe the task in two slots — *<what
to build> · done when <one observable result a reviewer can check on the
preview>* — and approve its plan. It opens one PR from a `claude/…` branch —
follow-ups update the same PR.

**Ship:** open the PR → check the checks and the Vercel **Visit Preview** link →
use *and* misuse the feature on the preview (never `main`'s URL) → when all green
and you're satisfied, **Approve → Merge**. A red check? Paste the error to Claude;
it fixes the same PR. `/verify` walks this for you.

**First time you build…** (the dashboard half of a feature — each is a one-time
click-path):
- **auth:** **Supabase → Authentication → URL Configuration** — set the Site URL
  to your production domain and add the preview/redirect URLs; the built-in mailer
  allows only a few emails per hour for the whole project, so use custom SMTP (or
  disable "Confirm email" while testing). If you seed a demo login in `seed.sql`,
  write its `auth.users` text token columns (`confirmation_token`,
  `recovery_token`, `email_change`, `email_change_token_new`) as `''` — a NULL
  there logs in as "Database error querying schema", and the row looks fine in the
  dashboard until someone tries it. If you load that demo user with test data
  (credits, owned items, a sample course) so the preview is explorable end to end,
  that's safe **only** because `seed.sql` runs on preview-branch resets and never
  on production deploy, and previews sit behind Vercel Authentication — so a weak
  demo credential and any god-mode balances can't reach production or a public
  URL. Never put such a user in a *migration* (migrations do run on production).
  *(verify against current Supabase branching docs.)*
- **a server secret** (AI key, payment key): **Supabase → Edge Functions →
  Secrets** — never the repo, never Vercel.
- **uploads:** size and MIME limits live in the bucket's migration, enforced
  server-side — ask Claude for them in the feature PR.

**✓** smoke-test the live site for 30 seconds. If something broke, go to
[Part 4](04-when-something-breaks.md) — nothing you did is irreversible. Check
meanings: `tests` = a test failed · `e2e` = a Playwright UI flow broke (download
the trace artifact) · `lint`/`typecheck` = style/type error · Supabase = migration
failed on the preview · Vercel = build failed · preview shows the "failed to start
/ missing config" message = env sync broken — go to
[step 6's ✗](02-set-it-up.md#6-set-up-vercel-and-connect-it-to-supabase) · an
"uptime: /health failing" issue appeared = production is down — go to
[Part 4](04-when-something-breaks.md) and roll back first.

---

Next: [Part 4 — When something breaks →](04-when-something-breaks.md)
