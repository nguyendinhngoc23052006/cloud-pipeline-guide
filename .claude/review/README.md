# .claude/review/

Before every guide-content PR, the orchestrator dispatches the three reviewers —
`editing-reviewer`, `consistency-reviewer`, `accuracy-reviewer` — and records each
one's verdict here as `<agent>.md`, refreshed for that PR.

These files are the **artifact that proves the review actually ran**. A promise
without an artifact is a review that silently didn't happen (the guide's own rule).
The reviewers are read-only and return their verdicts; the orchestrator writes them
here and is the only one that commits.
