# consistency-reviewer verdict — 2026-06-25

**Status:** PASS (CONCERNs raised, resolved before commit)

**Scope:** Prefix retirement + close/reopen retirement across all 4 framework copies;
new step 6.7 in Vite/Astro/SvelteKit; workaround rows removed; MEMORY.md updated.

**Initial CONCERNs:**
1. `docs/vite/02-set-it-up.md:304-306` — step 6 ✗ had "**push any commit**" (bolded)
   and "the preview redeploys automatically after syncing"; other three copies had unbolded
   "push any commit" and "after syncing, the integration redeploys the preview itself."
2. `docs/vite/02-set-it-up.md:577` — `/verify` skill said "close and reopen the PR";
   other three copies said "push any commit to the PR branch to retrigger env sync."

**Resolution:** Both items fixed in `docs/vite/02-set-it-up.md` to match the other copies.

**Post-fix checks:**
- Step 5.7 framework-specific prefixes: Vite → VITE_, Astro/SvelteKit → PUBLIC_,
  Next.js → absent (correct, native prefix already matches) — PASS.
- Step 5 note: Vite/Astro/SvelteKit say "redo step 5.6 and steps 6.5–6.7";
  Next says "redo step 5.6 and steps 6.5–6.6" — correct per-framework delta — PASS.
- Step 6 ✓: all 4 copies say "created at PR-open or on push" — PASS.
- Step 6 ✗: all 4 copies now byte-identical — PASS.
- /verify skill remedy: all 4 copies now byte-identical — PASS.
- Workaround table: all 4 copies have identical 3 rows (auth-seed, SessionStart,
  cdn.playwright.dev) — PASS.
- Routine prompts: all 4 copies have identical 2 items (auth-seed + SessionStart) — PASS.
- Decision-log env-seam bullets and verified-pass paragraphs: parallel across all 4
  copies with correct framework-specific prefix names — PASS.
- 06 env-name contract: each copy references its own framework-native prefix (VITE_ for
  Vite, NEXT_PUBLIC_ for Next, PUBLIC_ for Astro/SvelteKit) — PASS.

**Amendment (same PR):** Step 8.2 "Dependabot on self-hosted runners" warning — byte-identical text added to all 4 copies at the same paragraph position — PASS.

**Amendment 2 (same PR — stress-test finds):**
- Vite step 12 audit prompt only: "two-prefix fallback chain" → "single-prefix VITE_ supabaseClient" — framework-specific change (each copy describes its own scaffold); other 3 copies unchanged (they already described their framework-native prefix correctly).
- Step 12.4 "three clicks" → "settings" with self-hosted runners: byte-identical across all 4 copies — PASS.

**Amendment 3 (same PR — agent verification finds):**
- Step 4 scaffold prompt `runs-on` fix: byte-identical new wording ("no runner field — Dependabot uses GitHub-hosted runners unless the 'Dependabot on self-hosted runners' setting is ON") across all 4 copies — PASS.
- Step 5.1 GitHub-repo-prompt removal: byte-identical across all 4 copies; password urgency note "(you won't see it again)" added identically in all 4 copies — PASS.

**Verdict:** PASS.
