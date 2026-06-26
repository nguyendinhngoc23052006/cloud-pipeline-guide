# accuracy-reviewer verdict — PR: connectors/vercel-deploy/supabase-toggles (Jun 2026)

**Result: PASS** (after corrections applied this PR)

All five platform claims audited; three required factual corrections (applied this PR):

**Claim 1 — Claude Code GitHub App scope + "repository selector" UI label**
VERIFIED Jun 2026. Sources: code.claude.com/docs/en/claude-code-on-the-web and
code.claude.com/docs/en/web-quickstart. Confirmed verbatim: "a cloud session can
access any repository the connecting GitHub account can see, not just the repositories
the Claude GitHub App is installed on" and "click the repository selector below the
input box." Stamp added to step 2.1 in all 4 copies.

**Claim 2 — Vercel "Promote to Production" does not rebuild** — CORRECTED
"promotes the already-built code without a rebuild" was factually wrong. Verified
(vercel.com/docs/deployments/promoting-a-deployment): promoting a preview deployment
triggers a full rebuild using production environment variables. No-rebuild path is
Instant Rollback (reverts production; does not promote previews). Step 7 ✗ corrected
across all 4 copies. MEMORY.md updated.

**Claim 3 — Supabase Branching toggle independence**
PARTIALLY VERIFIED Jun 2026 — supabase.com discussion #32596 (official docs page 403'd).
Confirms: branch-specific credentials injected at PR-open without the Preview toggle;
Preview ON overwrites preview env vars with production credentials. Stamp added noting
partial verification source.

**Claim 4 — Integration injects ANON_KEY for previews** — CORRECTED
OUTDATED. New Supabase projects (Nov 2025+) receive PUBLISHABLE_KEY, not ANON_KEY.
Sources: supabase.com discussions #29260, #40717. The `?? ANON_KEY` fallback in client
code is still correct (covers legacy projects). Step 8 Note and step 8 ✓ updated across
all 4 copies to "either PUBLISHABLE_KEY (new) or ANON_KEY (legacy)." MEMORY.md corrected.

**Claim 5 — Vercel webhooks "occasionally fail" on merge**
OBSERVED PATTERN, not Vercel-documented behavior. Supported by community forum
(community.vercel.com) and Vercel's incident history (2025-2026). Wording changed
to "webhook delivery failures on merge have been reported in Vercel's community
forums and incident history" across all 4 copies.
