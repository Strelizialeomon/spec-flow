# spec-flow

给 AI 编码 agent 用的两段流程：**先把需求谈成 spec，再动代码；每份交付物要多少审核，由人说了算，不由 agent 自己定。**

[English](README.md) · **中文**

> 本 skill 的正文是中文（`SKILL.md` 与 `references/`），这份是中文全文。

<!-- s:problem -->
## 它解决什么

agent 很会产出，很不擅长先对齐。不管它，它会：

- 拿着半成形的需求就开写，你到看 diff 时才发现理解偏了；
- 一口气干完一大坨，走错一步就赔掉整坨；
- 说「已由独立审核复核」——而那个审核是它自己派的、自己写的 prompt、自己给的角度。

<!-- s:what -->
## 它是什么

不是代码生成器。是一套流程规矩（一个 markdown 文件加若干参考），agent 在动手做「值得先设计」的活之前加载它。两段流程，共用一道闸：

- **段一 · 方案期** —— 描述需求 → 一起确认需求 → agent 出 spec → spec 过 PR 和闸 → 合并 → 开 issue。此时一行代码都不写。
- **段二 · 实施期** —— 认领 issue（worktree 本身就是那把锁）→ 实施 → 过闸 → 合并 → 回填 issue、放锁。

到闸前，agent 把审核档位摆出来（不审 / 轻审 / 重审 / 重审 + 变异），**由你点**。它不替你点，也不会把「你没答」当成放行。

<!-- s:self-review -->
## 最值得拿走的一条：分身不是第二个人

agent 派出去的一切都还是它自己——同一件事、同一段 prompt、同一个看问题的框架，而且是想要放行的那一方自己挑的。所以分身的结论只有它自己的分量，一分不多。

因此 spec-flow 禁止 agent 替自己产出审核结论，也禁止它借名头（「已由独立审核通过」）来请你拍板。某一步真的需要一份不属于它的意见时，这一步就停下来，等人。

<!-- s:install -->
## 装

```bash
git clone https://github.com/Strelizialeomon/spec-flow.git ~/.claude/skills/spec-flow
```

装完就是全部——Claude Code 从 `~/.claude/skills/<名字>/SKILL.md` 读个人 skill。升级就是在那个目录里 `git pull`。

习惯把仓放在别处（作者就是这样），就 clone 到别处再软链进来：

```bash
git clone https://github.com/Strelizialeomon/spec-flow.git ~/code/spec-flow
ln -s ~/code/spec-flow ~/.claude/skills/spec-flow
```

要求：一个能读 skills 目录、能跑 shell 命令（`git worktree`）、能开 PR（`gh`）的 agent。已在 Claude Code 上验证；正文是纯 markdown，任何有 skills 目录的 harness 都能读。流程假定你用 GitHub。

<!-- s:usage -->
## 怎么用

描述一件值得先设计的活就能触发它——比如「这个改动要动接口、数据库和前端」——也可以直接点名调用。接下来 agent 会就它判断不了的岔路问你，把 spec 写进 `docs/specs/<日期>-<名字>.md`，开 PR，然后把审核档位摆给你点。

也可以从中间进：说「做 #12」就从段二开始，同样要过闸才能合。

想把它用到自己的仓里，说「把 spec-flow 应用到本项目」。它往那个仓的 `AGENTS.md` / `CLAUDE.md` 里写一段指针——指向这里，而不是抄一份正文，所以规矩永远只有一份。

<!-- s:evidence -->
## 本仓自己就是样板

spec-flow 是用 spec-flow 开发的。2026-10-15 这个时点的账面：109 次提交、54 个已合并 PR、14 个 issue、13 份 spec（`docs/specs/`），自 2026-09-22 跑起。每份 spec 是一次改动的设计记录，PR 的讨论里留着对它做的审核发现。

每条规矩都带一个编号——`（依据：rationale R16）`——指向 `references/rationale.md`，案例、统计或调研在那里。想知道一条流程规矩**为什么**长这样、而不只是它写了什么，那个文件就是读这个仓的理由。

<!-- s:docs -->
## 文件

| 文件 | 装什么 |
|---|---|
| `SKILL.md` | 流程正文——agent 加载的就是它 |
| `references/rationale.md` | 每条规矩的依据：案例、统计、调研（R1–R17） |
| `references/gate-details.md` | 闸怎么执行：审核、文档检查、一卡盖批 |
| `references/worktree-lock.md` | 认领 issue；worktree 那把锁，以及它怎么坏 |
| `references/spec-revision-sync.md` | 改一条判据要同步所有落点 |
| `references/split-large-spec.md` | 拆大 spec：交付物地图、依赖台账 |
| `references/adr-decision-records.md` | 可选：架构决策记录（ADR） |
| `references/documentation-lifecycle.md` | 可选：spec / ADR / issue 分工 |
| `references/issue-status-labels.md` | 可选：issue 状态标签 |
| `references/apply-to-project.md` | 「应用到项目」用的指针块模板 |
| `references/adoption-model.md` | 采纳模型的来龙去脉 |
| `docs/maintainer-notes.md` | 本仓自己的说明：这份检出怎么接的线、最早的提交为什么是重建的 |
| `scripts/check-docs.sh` | 文档检查：SKILL.md 体量、references 路径、README 双语同步 |

哪个参考什么时候读，见 `SKILL.md` 末尾那张表。

<!-- s:contributing -->
## 参与

小步来。开个 issue，或者直接发 PR。一条约定：改动新增或修改了规矩，就把背后的案例记进 `references/rationale.md`、编个新 `R` 号——这里的规矩得指得出发生过的事。

<!-- s:license -->
## 许可

MIT，见 [LICENSE](LICENSE)。
