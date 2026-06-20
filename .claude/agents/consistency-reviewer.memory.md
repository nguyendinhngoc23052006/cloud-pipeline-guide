# consistency-reviewer — memory

Lessons this agent has learned, one per line; prune to keep it short. The
orchestrator updates this file (the agent itself is read-only).

- Parts 03/04/05 are byte-identical across every `docs/<framework>/` copy — diff
  them across copies first; any difference is drift unless it is genuinely
  framework-specific.
- The `## For you` template (fixed headings: `What changed:` / `What you do next:` /
  `How to roll it back:`) and any constitution rule about PR-body content are wired
  to each other — same pipe. A change to one without checking the other is a
  pipe-moved-alone violation (Jun 2026 — caught a contradiction in the new
  `## How you communicate` PR-description bullet before it shipped).
- A significant constitution addition (a new section or a new sub-principle) is
  also a `07-decision-log.md` entry — every prior such addition has one. Flag the
  missing entry as a hard requirement, not a nice-to-have.
