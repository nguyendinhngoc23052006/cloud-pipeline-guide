# editing-reviewer verdict — PR: connectors/vercel-deploy/supabase-toggles (Jun 2026)

**Result: PASS** (after fixes applied this PR)

Two arrow violations found and fixed:

1. **Step 7 ✗ — prose before first arrow** (`docs/<fw>/02-set-it-up.md`, all 4 copies)
   "a merge to `main` doesn't trigger a Vercel production deployment →" — prose on the left of `→`.
   Fixed: replaced `→` with `— go to`, making it a sentence rather than an arrow chain.

2. **Step 14.4 — prose after last on-screen label** (`docs/<fw>/02-set-it-up.md`, all 4 copies)
   "**Create a new repository** → start a new cloud session" — prose on the right of `→`.
   Fixed: replaced `→` with `; then`.

No other violations in the changed sections (step 2.1, step 2 ✓, step 8.3, step 8 Note, step 8 ✓).

*Lesson: The arrow rule applies to any guide prose, not only numbered action steps. A ✗ block that begins with a prose condition and then uses → to reach an on-screen label violates it just as a numbered step would.*
