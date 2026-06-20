# editing-reviewer — memory

Lessons this agent has learned, one per line; prune to keep it short. The
orchestrator updates this file (the agent itself is read-only).

- The arrow rule (→ only between literal on-screen labels) applies to **constitution
  content inside the step-3 fenced markdown block** of `docs/<framework>/02-set-it-up.md`,
  not just to numbered guide actions. Caught Jun 2026 — author had used `→` for
  prose-fragment shorthands in dense bullets ("20+ → decompose"; "one-line ask →
  one-line answer"). Rewrite as full sentences with verbs.
- The constitution block has **pre-existing arrow violations** that predate the
  Jun 2026 meta-behavior PR — `02-set-it-up.md:140` (Memory "Cycle" bullet, 3
  arrows), `:141` (Memory "Worked/failed", 2 arrows), `:144` (Your place "Flow",
  2 arrows). Identical across all 4 framework copies. Sweep the full constitution
  block for arrow-rule compliance in a follow-on surgical PR.
- The `## For you` template in `Your place + every-PR rules` has FIXED headings
  (`What changed:` / `What you do next:` / `How to roll it back:`); any new
  constitution rule about PR-body content must harmonize with these headings, not
  contradict them. The PR-body bullet in `## How you communicate` was tuned to
  describe what sits *above* the block, not to override it.
