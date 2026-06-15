# Part 5 — Honest limits

> **This part guides you to:** know what the pipeline can't do, so you don't
> trust it past its edges. Read once; revisit before going live.

- Claude Code cloud is **beta**, but the gates live in GitHub/Supabase/Vercel — if
  it wobbles, point another tool at the same repo.
- A preview is a full isolated instance, so logins/uploads/migrations are testable
  — but it can't reproduce real production **traffic**.
- Most money mistakes have a cure (refund/void/cancel); only a truly irreversible
  external effect is prevention-only.

*Before real users: RLS on every table, and no secret key in client code.*

---

Next: [Keeping it current →](06-keeping-it-current.md)
