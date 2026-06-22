# code-reviewer verdict — 2026-06-22

PR: guide repo — dependabot auto-merge + Claude Code settings docs (all 4 frameworks)

## PASS

All four framework copies (`docs/vite/`, `docs/astro/`, `docs/next/`, `docs/sveltekit/`) are byte-identical in shared sections (steps 2.6, 8.2, 9.7, common parts of 12.1). Framework-specific audit prompts in step 12.1 correctly differ per framework.

**Checks passed:**
- Consistency across copies — shared prose matches byte-for-byte.
- Connected-line principle — step 12.4 correctly references step 8.2's "three clicks" and lists them accurately; step 12.1 audit prompt includes `dependabot-auto-merge.yml`.
- Paste prompt accuracy — workflow prompt is technically sound: `pull_request_target`, `dependabot/fetch-metadata@v2`, correct condition on `version-update:semver-patch`, `gh pr merge --auto --squash` with correct env vars.
- Bypass clarity — step 9 note and inline explanation both state CI still runs and must pass; bypass is approval-only.
- Editing rules — numbered actions first then single italic *note*; prompts inline; no forward references.
