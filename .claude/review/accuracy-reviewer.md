# accuracy-reviewer verdict — 2026-06-25

**Status:** PASS (CONCERN raised, resolved before commit)

**Scope:** Prefix retirement + close/reopen retirement across all 4 framework copies;
new step 6.7 (moved from initially-drafted step 5.7); workaround rows removed; MEMORY.md updated.

**Initial CONCERN:**
`docs/vite/02-set-it-up.md:300` (step 6 ✓) — said "created at PR-open" without
mentioning the push/branch-creation trigger, while the decision-log and ✗ both
document that env sync fires at PR-open AND on push/branch creation. Other three copies
already said "created at PR-open or on push."

**Resolution:** Vite step 6 ✓ updated to "created at PR-open or on push" — now
consistent with the documented behavior and the other three copies.

**Platform claims checked:**
- "Supabase→Vercel integration's per-connection prefix is configurable" —
  stamp: `*(docs + field, Jun 2026; supabase/supabase PR #28058 merged Jul 2024)*` — PASS.
- "Env sync fires at PR-open AND on push/branch creation" —
  stamp: `*(field, Jun 2026)*` — PASS.
- "For Next.js the integration default NEXT_PUBLIC_ prefix is already correct — no
  change needed" — stamp: `*(field, Jun 2026)*` — PASS.
- Step 5.7 dashboard path "Supabase → Project → Settings → Integrations → Vercel →
  Manage → Prefix → Save" — field-verified Jun 2026 per MEMORY.md:57-59 — PASS.
- MEMORY.md per-framework wiring section updated with canonical stamps — PASS.

**Amendment (same PR):** Step 8.2 "Dependabot on self-hosted runners" warning — claim: "if it is ON with no self-hosted runners, Dependabot jobs queue indefinitely and never run" — confirmed by the user's own observation (their edu repo had this ON and Dependabot was silently broken); matches GitHub's documented behavior that Dependabot jobs routed to self-hosted runners require a self-hosted runner to be available — PASS.

**Amendment 2 (same PR — stress-test finds):**
- Vite step 12 audit prompt: "single-prefix VITE_ supabaseClient (VITE_SUPABASE_URL, VITE_SUPABASE_PUBLISHABLE_KEY)" — accurately describes what the step 4 scaffold creates after prefix retirement; no unverifiable platform claim — PASS.
- Step 12.4: enumerating "self-hosted runners OFF" in the parenthetical — consistent with the step 8.2 setting now documented — PASS.

**Amendment 3 (same PR — agent verification finds):**
- Step 4 scaffold prompt `runs-on` wording (all 4 copies): previous text said "omit the runs-on field — Dependabot uses GitHub-hosted runners by default" implying `runs-on` is a valid `dependabot.yml` option. Confirmed against GitHub's official Dependabot configuration options reference *(docs, Jun 2026)*: `runs-on` does not exist in the `dependabot.yml` schema. Fixed to "no runner field — Dependabot uses GitHub-hosted runners unless the 'Dependabot on self-hosted runners' setting is ON" — PASS.
- Step 5.1 "choose your GitHub repo when prompted" (all 4 copies): claim that Supabase New Project wizard prompts for GitHub repo selection. Confirmed against current Supabase documentation *(docs, Jun 2026)*: GitHub repo connection is a separate step (step 5.6, Organization → Integrations → GitHub Connections) and is never prompted during project creation. Text removed; password urgency note "(you won't see it again)" added — PASS.

**Verdict:** PASS.
