# docs/ — local conventions (folder memory)

Each `docs/<framework>/` is a COMPLETE, standalone guide (Parts 01–07) for one
framework; a reader follows one folder end to end and never needs another.

- **Framework-independent parts are byte-identical across copies** — Parts 03 (ship),
  04 (breaks), 05 (limits), and any framework-neutral prose elsewhere. Change them in
  EVERY copy in the same PR. To check drift: diff a part across copies.
- **Framework-specific parts differ per copy** — touch only that framework's copy:
  the env-name-contract paragraph in 01; the pasted app-`CLAUDE.md` block, the
  scaffold prompt, the public env prefix, and the integration sub-step count in 02 (steps 4, 5, 7.2, and 8); the env-name
  contract section + workaround table in 06; the env-seam and testing bullets in 07.
- **Keep copies parallel** — same step numbers, section headings, and filenames, so
  the README chooser and every cross-reference keep resolving.
- **Editing rules** (full version atop each `07-decision-log.md`): numbered actions
  then one italic *note*; strictly linear (later needs earlier); arrows (→) only
  between literal on-screen labels; prompts inline under the line that pastes them;
  verify every platform claim against current official docs and stamp it.
