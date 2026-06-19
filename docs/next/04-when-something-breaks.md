# Part 4 — When something breaks

> **This part guides you to:** pick the right undo when a merge causes trouble —
> code, schema, data, or payment. Reached from Part 3's ✓ when a smoke-test
> fails.

*`/revert` routes you to the right fix.*

- **Bad code:** roll back to the last good deployment — in Vercel, open
  **Deployments**, find the most recent deployment that worked, and click **⋯ →
  Promote to Production** (instant). Then tell Claude to revert the bad PR in Git
  so the broken code can't redeploy.
- **Bad schema:** tell Claude "write a migration that reverses PR #X" and ship
  that fix through a normal PR.
- **Lost/corrupt data:** in Supabase, open project's database, then **Backups (PITR)** and restore the
  database to a moment before the bad deploy. This rewinds *everything*, so it's
  the last resort.
- **Payment:** reverse at the provider — refund/void/cancel.

**In a panic:** roll back in Vercel first, then revert the code, and touch the
database only if data is actually wrong.

---

Next: [Part 5 — Honest limits →](05-honest-limits.md)
