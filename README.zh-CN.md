# spec-flow

**一套把返工推到你最便宜那一刻的 AI 编码流程。** 代码还不存在就先谈定 spec，把活放上两段流程、共用一道闸；每份要多少审核，由人说了算，不由 agent 自己定。

[English](README.md) · **中文**

> 本 skill 的正文是中文（`SKILL.md` 与 `references/`），这份是中文全文。

这里的规矩是从真事里长出来的。[`references/rationale.md`](references/rationale.md) 存着这份档案——**22 条，每条带着案例、数字或调研。**

<!-- s:problem -->
## 它解决什么

agent 很会产出，很不擅长先对齐。不管它，它会：

- **拿着半成形的需求就开写**——你到看 diff 时才发现理解偏了，而那时下游已经全建在这个误解上了；
- **一口气干完一大坨**——中间没有一处能拦住那个错假设的检查点，走错一步赔掉整坨；
- **说「已由独立审核复核」**——而那个审核是它自己派的、自己写的 prompt、自己给的角度，还是想要放行的那一方自己挑的。你以为多了一双眼睛，其实一双都没有。

<!-- s:what -->
## 它怎么解决

**两段流程，共用一道闸。**

- **段一 · 方案期** —— 描述需求 → 一起确认需求 → 出 spec → 过 PR 和闸 → 合并 → 开 issue。此时一行代码都不写。
- **段二 · 实施期** —— 认领 issue（worktree 本身就是那把锁）→ 实施 → 过闸 → 合并 → 回填 issue、放锁。

共用的那道闸上，agent 把审核档位摆出来——**不审 / 轻审 / 重审 / 重审 + 变异**——由**你**点，每份交付物各点一次，不沿用上一份。

每一步都为一件叫得出名字的事故存在：

| 这一步 | 它堵的是 |
|---|---|
| 确认需求是一道硬关口——你没点头，spec 文件碰都不许碰 | 那个你本来要在 diff 里才撞见的误解 |
| 每份交付物各过各的闸 | 走错一步赔掉一整坨 |
| agent 不许替自己产出审核结论 | 那场根本没发生过的审核 |
| issue 锚着 spec 合并后的永久链接 | 「当初为什么这么做」漂得找不回来 |

<!-- s:self-review -->
## 最值得拿走的一条：分身不是第二个人

agent 派出去的一切都还是它自己——同一件事、同一段 prompt、同一个看问题的框架，而且是想要放行的那一方自己挑的。所以分身的结论只有它自己的分量，一分不多。

因此 spec-flow 禁止 agent 替自己产出审核结论：审不审、审哪档由你点，它不许自己派一个来替它判。某一步真的需要一份不属于它的意见时，这一步就停下来，等人。

<!-- s:smooth -->
## 为什么它不累赘

它不是往 agent 身上绑约束，是把返工挪到返工便宜的地方去——而且每个机制都刻意做到**尽量少占用你的注意力**。

| 这么设计 | 丝滑在哪 |
|---|---|
| 档位按每份交付物当场点，不可沿用 | 成本跟着风险走：**不审 / 轻审 / 重审 / 重审 + 变异**。改一行文档零成本，改核心才上两个审核。没有一刀切的口径要吵。 |
| 卡没答，绝不替你加码 | 六张卡的默认值全都躲开「往前加东西」那一侧：不审、不合、不出 spec、不纳入、不动笔。 |
| 打断按「要不要你答」分层 | 新增的机制单独一张卡——那正是你事后会问「这是什么、哪来的」的东西。agent 自己定的其余细节（默认值、命名、落点）统一列在末尾一块，扫一眼就行，不逐项问。 |
| 判断权从 agent 手里收走 | 它不许自己判「这次算不算核心」。省掉的不只是风险，是那场论证。 |
| 从事故里长出来的规矩带着 `R` 编号 | 不认同它？那件事就在一跳之外。不用从头重新吵。 |

<!-- s:longrun -->
## 它凭什么扛得住长活

**状态存在 git 里，不存在 agent 的脑袋里。**

| 想知道 | 写在哪 | 为什么信得过 |
|---|---|---|
| 谁在做 | worktree 的名字——锁本身 | 开 `issue-42` 开得成 = 没人做；被拒 = 有人在做。（`git worktree list` 能一眼看全，但锁本身是「开得成」这件事。）没有另一张会对不上的任务分配表。 |
| 做到哪了 | issue 的状态和 PR | 持久，跨会话可读，换台机器、交给别人，还是同一份。 |
| 当初为什么这么做 | `docs/specs/` 里的 spec，issue 链过去 | 它过了闸、是人话、跟着代码一起版本化——能 diff、能 blame、能回滚。 |

把这类东西存在自己私有索引里的工具，漂了不会告诉你。这个不会：git 会在出事的那一刻当场喊出来。

<!-- s:limits -->
## 它不做什么

- **它不记得过程。** 试过什么又放弃了、哪个死胡同耗了一小时、你上次卡在第几步——没写下来的就没了。写下来的那部分是审核留痕：每条发现和它的处置，追加在 spec 末尾。所以新会话读到的是「要做什么、做到哪、上次抓出了什么」，读不到「那条没走的路为什么没走通」。
- **它不是运行时。** 这里没有任何东西会去调度 agent、给一次跑留检查点、或者把凌晨三点挂掉的那次续起来。它假定你在场，站在闸前面。
- **它假定你用 GitHub。** issue 和 PR 在这里是承重墙，不是装饰。

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

要求：一个能读 skills 目录、能跑 shell 命令（`git worktree`）、能开 PR（`gh`）的 agent。已在 Claude Code 上验证；正文是纯 markdown，任何有 skills 目录的 harness 都能读。

<!-- s:usage -->
## 怎么用

描述一件值得先设计的活就能触发它——比如「这个改动要动接口、数据库和前端」——也可以直接点名调用。接下来 agent 会就它判断不了的岔路问你，把 spec 写进 `docs/specs/<日期>-<名字>.md`，开 PR，然后把审核档位摆给你点。

也可以从中间进：说「做 #12」就从段二开始，同样要过闸才能合。

想把它用到自己的仓里，说「把 spec-flow 应用到本项目」。它往那个仓的 `AGENTS.md` 里写一段指针（只有在那个仓已有 `CLAUDE.md` 时，才往 `CLAUDE.md` 补一行 `@AGENTS.md` 导入）——指向这里，而不是抄一份正文，所以规矩永远只有一份。

<!-- s:evidence -->
## 本仓自己就是样板

spec-flow 是用 spec-flow 开发的。2026-10-16 这个时点的账面：64 个已合并 PR、17 个 issue、16 份 spec（`docs/specs/`）。每份 spec 是一次改动的设计记录；过了审核的那些 PR，讨论里留着发现——包括后来改掉了规矩的发现。

规矩旁边带着依据指针（如 `（依据：rationale R12）`），指向 [`references/rationale.md`](references/rationale.md)，案例、统计或调研在那里——反爬专项里判据在一处放宽、另外四处连同父文档总纲都没跟着改，照那份 spec 施工做出来的是旧行为；还有那条让「没有 bug」不再等于「我们保证以后永不出错」的完成标准。想知道一条流程规矩**为什么**长这样、而不只是它写了什么，那个文件就是读这个仓的理由。

<!-- s:docs -->
## 文件

| 文件 | 装什么 |
|---|---|
| `SKILL.md` | 流程正文——agent 加载的就是它 |
| `AGENTS.md` | 本仓的维护规矩（给 agent 看的） |
| `CLAUDE.md` | 一行 `@AGENTS.md` |
| `references/rationale.md` | 每条规矩的依据：案例、统计、调研（R1–R22） |
| `references/gate-details.md` | 闸怎么执行：审核、文档检查、一卡盖批 |
| `references/worktree-lock.md` | 认领 issue；worktree 那把锁，以及它怎么坏 |
| `references/spec-revision-sync.md` | 改一条判据要同步所有落点 |
| `references/split-large-spec.md` | 拆大 spec：交付物地图、依赖台账 |
| `references/adr-decision-records.md` | 可选：架构决策记录（ADR） |
| `references/documentation-lifecycle.md` | 可选：spec / ADR / issue 分工 |
| `references/issue-status-labels.md` | 可选：issue 状态标签 |
| `references/apply-to-project.md` | 「应用到项目」用的指针块模板 |
| `references/adoption-model.md` | 可选：「应用到项目」背后的三层采纳模型 |
| `docs/maintainer-notes.md` | 本仓自己的说明：这份检出怎么接的线、最早的提交为什么是重建的 |
| `scripts/check-docs.sh` | 文档检查：SKILL.md 体量、references 路径、README 双语同步、采用契约 |

流程正文是 `SKILL.md`——这份 README 与它说法不一致时，以 `SKILL.md` 为准。哪个参考什么时候读，见 `SKILL.md` 末尾那张表。

<!-- s:contributing -->
## 参与

小步来。开个 issue，或者直接发 PR。一条约定：改动新增或修改了规矩，就把背后的案例记进 `references/rationale.md`、编个新 `R` 号——这里的规矩得指得出发生过的事。

<!-- s:license -->
## 许可

MIT，见 [LICENSE](LICENSE)。
