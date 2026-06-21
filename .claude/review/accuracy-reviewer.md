# accuracy-reviewer verdict — 2026-06-21

**Status:** PASS (after correction applied by orchestrator)

**Scope:** new `## Renaming the project` section in all 4 `docs/<framework>/06-keeping-it-current.md` copies.

**Initial finding (corrected before commit):**
- Step 3 used "Supabase dashboard → **Project Settings → Integrations**" — contradicts Part 2 step 5.6's "Organization → Integrations → GitHub Connections". Fixed to match step 5.6 path; section now explicitly references step 5.6 for consistency.

**Claims and stamps:**

| Claim | Stamp | Source |
|---|---|---|
| GitHub git redirects break if old name is reused | *(docs, Jun 2026)* | docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository |
| Supabase data safe; branch sync breaks until reconnect | *(docs, Jun 2026)* | supabase.com/docs/guides/deployment/branching/github-integration |
| Vercel Deployment Checks track CI job names, not project/repo name | *(docs, Jun 2026)* | vercel.com/docs/deployment-checks |
| Supabase reconnect path: Organization → Integrations → GitHub Connections | matches Part 2 step 5.6 (field, Jun 2026) | — |

**Unverifiable items (noted, not blocking):**
- Whether `*.vercel.app` URL changes on Vercel project rename (Vercel KB page 403'd during research) — step 5 uses "may change" framing implicitly via "replace with the new `*.vercel.app` URL", which is safe.
- Whether Supabase→Vercel marketplace integration needs re-linking after rename — not asserted in the section; not a blocking gap.

**Verdict:** PASS.
