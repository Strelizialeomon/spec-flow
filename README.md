# spec-flow

**A process for AI coding agents that moves every rework to its cheapest moment.** Agree on the spec before any code exists, run it through two phases and one shared gate, and let a human — not the agent — decide how much review each deliverable gets.

**English** · [中文](README.zh-CN.md)

> The workflow itself is written in Chinese (`SKILL.md` and `references/`). This README is the English entry point, so you can tell whether it's for you before opening anything.

The rules here grew out of things that actually happened. [`references/rationale.md`](references/rationale.md) keeps the dossier — 22 entries, each with the case, the number or the investigation behind it.

<!-- s:problem -->
## The problem

Agents are good at producing work and bad at stopping to align first. Left alone they will:

- **start coding from a half-formed request** — and you only meet the misunderstanding in the diff, by which point everything downstream has been built on top of it;
- **finish a large chunk in one go** — so there is no checkpoint where the wrong assumption could have been caught, and one wrong turn costs the whole chunk;
- **report "an independent reviewer checked this"** when the reviewer was a subagent they spawned, prompted, and framed themselves — chosen by the party that wants the green light. You think a second pair of eyes looked at it. None did.

<!-- s:what -->
## How it solves them

**Two phases, one shared gate.**

- **Phase 1 · design** — describe the need → agree on it → spec → PR → gate → merge → the spec gets its own issue. No code yet.
- **Phase 2 · implementation** — claim the issue (the git worktree *is* the lock) → implement → gate → merge → backfill the issue and release the lock.

At the shared gate the agent lays out the review levels — **none / light / heavy / heavy + mutation testing** — and **you** pick one, fresh for each deliverable. Nothing carries over from the last one.

Each step exists for a failure you can name:

| The step | The failure it stops |
|---|---|
| Agreeing on the need is a hard gate — no spec file gets touched until you nod | the misunderstanding you'd otherwise meet in the diff |
| Every deliverable passes its own gate | one wrong turn costing the whole chunk |
| The agent may not produce a review verdict on its own behalf | the review that never happened |
| An issue anchors a permanent link to the merged spec | "why was it built this way" drifting out of reach |

<!-- s:self-review -->
## The part worth stealing: a subagent is not a second opinion

Everything the agent spawns is still the agent — same task, same prompt, same framing, chosen by the party who wants the green light. So a subagent's conclusions weigh exactly as much as the agent's own. No more.

spec-flow therefore forbids the agent from producing a review verdict on its own behalf: the review level is yours to pick, and it may not dispatch a reviewer to do the judging for it. When a step genuinely needs an opinion that isn't the agent's, that step stops and waits for a human.

<!-- s:smooth -->
## Why it doesn't feel heavy

It isn't restraint bolted onto the agent. It's rework moved to where rework is cheap — and every mechanism is shaped to cost you as little attention as possible.

| The design | Why it's smooth |
|---|---|
| The review level is chosen per deliverable and never inherited | Cost tracks risk: **none / light / heavy / heavy + mutation testing**. A one-line doc change costs nothing; a core change gets two reviewers. No blanket policy to argue about. |
| An unanswered card never adds anything | All six cards default away from action: no review, no merge, no new spec, no exception, no edit. |
| Interruptions are split by whether they need an answer | A new mechanism gets its own card, because that's the thing you'd later ask "what is this, and where did it come from". Everything else the agent decided by itself — defaults, naming, where things land — is listed in one block at the end for you to skim, not answer one by one. |
| The judgment is taken away from the agent | It may not decide "this one counts as core." That removes the argument, not just the risk. |
| A rule that came out of an incident cites it by `R` number | Disagree with that rule and the incident is one hop away. You never re-litigate it from scratch. |

<!-- s:longrun -->
## Why it survives long work

**State lives in git, not in the agent's head.**

| To know | It's written in | Why you can trust it |
|---|---|---|
| Who is working on it | the worktree name — the lock itself | Creating `issue-42` succeeds = nobody has it; refused = somebody does. (`git worktree list` shows the same thing at a glance, but the lock is the create succeeding.) No separate assignment board to fall out of sync. |
| How far along it is | the issue's state and the pull request | Durable, readable across sessions, unchanged when you switch machines or hand it to someone else. |
| Why it was built that way | the spec in `docs/specs/`, linked from the issue | It passed the gate, it's in prose, and it's versioned with the code — diffable, blamable, revertable. |

Tools that keep this in their own private index drift without telling you. This one can't: git says so, loudly, at the moment it happens.

<!-- s:limits -->
## What it doesn't do

- **It doesn't remember the process.** What was tried and abandoned, which dead end cost an hour, which step you were mid-way through — if it wasn't written down, it's gone. One part does get written down: the review trail, each finding and how it was disposed of, appended to the spec. So a new session reads *what to do*, *how far along*, and *what was caught last time* — but not *why the road not taken didn't work*.
- **It isn't a runtime.** Nothing here schedules an agent, checkpoints a run, or resumes one that died at 3am. It assumes you are there for the gate.
- **It assumes GitHub.** Issues and pull requests are load-bearing, not decoration.

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

Requirements: an agent that can read a skills directory, run shell commands (`git worktree`), and open PRs (`gh`). Verified with Claude Code; the content is plain markdown, so any harness with a skills directory can read it.

<!-- s:usage -->
## Using it

Trigger it by describing work that deserves designing — "this touches the API, the DB and the frontend" — or invoke it by name. From there the agent asks about the forks it cannot decide, writes a spec to `docs/specs/<date>-<name>.md`, opens a PR, and hands you a review card.

You can also enter from the middle: "do #12" starts phase 2 for an existing issue, and still passes the gate before merging.

To adopt it in one of your own repos, say *"apply spec-flow to this project"*. It writes a pointer block into that repo's `AGENTS.md` — adding the one-line `@AGENTS.md` import to `CLAUDE.md`, and only when that file already exists — pointing here rather than copying the rules, so there is only ever one copy to maintain.

<!-- s:evidence -->
## This repo is its own case study

spec-flow is developed with spec-flow. As of 2026-10-16: 64 merged PRs, 17 issues, 16 specs in `docs/specs/`. Each spec is the design record of one change; the PRs that went through a review hold its findings in the discussion, including the findings that changed a rule.

Clauses carry a pointer like `（依据：rationale R12）` into [`references/rationale.md`](references/rationale.md), where the case, the statistic or the research behind that rule lives — the anti-scraping job where a judgement criterion was widened in one place and left stale in four others plus the parent document's overview, so building from the spec would have produced the old behaviour; the completion contract that stops "no bugs" from meaning "we promise nothing will ever break". If you want to know *why* a process rule looks the way it does, not just what it says, that file is the reason to read this repo.

<!-- s:docs -->
## Files

| File | What's in it |
|---|---|
| `SKILL.md` | The workflow itself — the file the agent loads |
| `AGENTS.md` | This repo's maintenance rules for the agent |
| `CLAUDE.md` | One line: `@AGENTS.md` |
| `references/rationale.md` | Why each rule exists: cases, numbers, research (R1–R22) |
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
