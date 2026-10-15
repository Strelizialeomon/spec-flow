# spec-flow

A two-phase workflow for AI coding agents: settle the spec before any code gets written, and let the human — not the agent — decide how much review each deliverable gets.

**English** · [中文](README.zh-CN.md)

> The workflow itself is written in Chinese (`SKILL.md` and `references/`). This README is the English entry point, so you can tell whether it's for you before opening anything.

<!-- s:problem -->
## The problem

Agents are good at producing work and bad at stopping to align first. Left alone they will:

- start coding from a half-formed request, and you only meet the misunderstanding in the diff;
- finish a large chunk in one go, so one wrong turn costs the whole chunk;
- report "an independent reviewer checked this" when the reviewer was a subagent they spawned, prompted, and framed themselves.

<!-- s:what -->
## What it does

spec-flow is not a code generator. It's a set of process rules — one markdown file plus references — that the agent loads before doing work worth designing. Two phases, one shared gate:

- **Phase 1 · design** — describe the need → agree on it → the agent writes a spec → the spec goes through a PR and the gate → merge → the spec gets its own issue. No code yet.
- **Phase 2 · implementation** — claim the issue (the git worktree *is* the lock) → implement → gate → merge → backfill the issue and release the lock.

At the gate, the agent lays out the review levels (none / light / heavy / heavy + mutation testing) and **you** pick one. It never picks for you — an unanswered review card falls back to *no review*, and for the cards that govern a merge or the fate of a known problem, no answer means no merge.

<!-- s:self-review -->
## The part worth stealing: a subagent is not a second opinion

Everything the agent spawns is still the agent — same task, same prompt, same framing, chosen by the party who wants the green light. So a subagent's conclusions weigh exactly as much as the agent's own. No more.

spec-flow therefore forbids the agent from producing a review verdict on its own behalf, and forbids it from borrowing authority ("an independent reviewer approved this") when it asks you to sign off. When a step genuinely needs an opinion that isn't the agent's, that step stops and waits for a human.

<!-- s:install -->
## Install

```bash
git clone https://github.com/Strelizialeomon/spec-flow.git ~/.claude/skills/spec-flow
```

That's the whole install — Claude Code loads personal skills from `~/.claude/skills/<name>/SKILL.md`. Updating is `git pull` inside that directory.

If you keep your repos elsewhere (as the author does), clone anywhere and symlink it in:

```bash
git clone https://github.com/Strelizialeomon/spec-flow.git ~/code/spec-flow
ln -s ~/code/spec-flow ~/.claude/skills/spec-flow
```

Requirements: an agent that can read a skills directory, run shell commands (`git worktree`), and open PRs (`gh`). Verified with Claude Code; the content is plain markdown, so any harness with a skills directory can read it. The workflow assumes GitHub.

<!-- s:usage -->
## Using it

Trigger it by describing work that deserves designing — "this touches the API, the DB and the frontend" — or invoke it by name. From there the agent asks about the forks it cannot decide, writes a spec to `docs/specs/<date>-<name>.md`, opens a PR, and hands you a review card.

You can also enter from the middle: "do #12" starts phase 2 for an existing issue, and still passes the gate before merging.

To adopt it in one of your own repos, say *"apply spec-flow to this project"*. It writes a pointer block into that repo's `AGENTS.md` — adding the one-line `@AGENTS.md` import to `CLAUDE.md`, and only when that file already exists — pointing here rather than copying the rules, so there is only ever one copy to maintain.

<!-- s:evidence -->
## This repo is its own case study

spec-flow is developed with spec-flow. As of 2026-10-15: 57 merged PRs, 15 issues, 14 specs in `docs/specs/`, running since 2026-09-22 — each spec is the design record of one change, and its PR discussion holds the review findings.

Clauses carry a pointer like `（依据：rationale R12）` into `references/rationale.md`, where the case, the statistic or the research behind that rule lives. If you want to know *why* a process rule looks the way it does, not just what it says, that file is the reason to read this repo.

<!-- s:docs -->
## Files

| File | What's in it |
|---|---|
| `SKILL.md` | The workflow itself — the file the agent loads |
| `AGENTS.md` | This repo's maintenance rules for the agent |
| `CLAUDE.md` | One line: `@AGENTS.md` |
| `references/rationale.md` | Why each rule exists: cases, numbers, research (R1–R20) |
| `references/gate-details.md` | How the gate runs: reviews, doc checks, batching |
| `references/worktree-lock.md` | Claiming an issue; the worktree lock, and how it breaks |
| `references/spec-revision-sync.md` | Changing one clause means syncing every place it lands |
| `references/split-large-spec.md` | Splitting a big spec: deliverable map, dependency ledger |
| `references/adr-decision-records.md` | Optional: architecture decision records |
| `references/documentation-lifecycle.md` | Optional: spec / ADR / issue division of labour |
| `references/issue-status-labels.md` | Optional: issue status labels |
| `references/apply-to-project.md` | The pointer-block templates behind "apply to this project" |
| `references/adoption-model.md` | Optional: the three-layer adoption model behind "apply to this project" |
| `docs/maintainer-notes.md` | Repo-local notes: how this checkout is wired, why the first commits are reconstructed |
| `scripts/check-docs.sh` | Document checks: SKILL.md budget, reference paths, README sync, adoption contract |

The workflow itself is `SKILL.md`; where this README and that file disagree, `SKILL.md` wins. Which reference to read when is listed at the bottom of `SKILL.md`.

<!-- s:contributing -->
## Contributing

Keep it small. Open an issue, or send a PR. One convention: if your change adds or alters a rule, record the case behind it in `references/rationale.md` under a new `R` number — rules here are supposed to be able to point at something that actually happened.

<!-- s:license -->
## License

MIT — see [LICENSE](LICENSE).
