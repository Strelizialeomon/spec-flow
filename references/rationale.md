# 依据档案（rationale）：规则背后的案例、统计与来龙去脉

> **备忘录，不是规程**——`SKILL.md` 不依赖本文件，没读它流程照走。
> 主文件规则旁只留一句理由 +「（依据：rationale Rn）」，案例、复盘统计、来龙去脉收在这里，按 R 编号（编号不随标题改动失效）。
> **新增规则时**：案例 / 统计 / 来龙去脉写这里、编新 R 号；主文件只留一句理由和指针。
> R1–R9 是 2026-09-26（#37）从 `SKILL.md` 逐字搬入的原文，未改写；「原文」取改前 `SKILL.md`（main `dd109e9`）中含挪出片段的那几行（去掉了列表缩进），行号为含 frontmatter 的全文行号。

## R1 改判据要同步所有落点（第 5 步）

- 原位置：改前 `:61-63`；整段挪走。
- 主文件现留的一句理由：只改判据那一句、别处不同步，照 spec 施工等于白改。

原文：

**为什么有这条**（2026-09-11 反爬专项的实例）：把 IDC 判据从「CIDR 段」扩成「CIDR ∪ ASN」，
**只改了判据那一句** —— 机制、实现、实施步骤、验收四处全没动，父文档总纲 §0 也没改。
**照当时的 spec 施工会做成 CIDR-only，等于白改。**独立审核抓出 2 处严重。

## R2 issue 的开单时机（第 6 步）

- 原位置：改前 `:71`；挪走「（owner 2026-09-01 钦定）」与其后的理由全文。
- 主文件现留的一句理由：issue 锚的是 main 上 spec 的永久链接，spec 没定稿就开 issue 会两边互相引着改。

原文：

- ⏰ **时机：spec PR 合并之后、代码实施之前**（owner 2026-09-01 钦定）。理由是 issue 锚的是 main 上 spec 的**永久链接**，必须等 spec 定稿合并；反过来先开 issue 后合并 PR，issue 引用的 spec 还在被审核修订，两边互相引着改，麻烦。代码实施是 issue 开出来后认领——认领动作与防撞锁见第 7 步「认领与防撞车」

## R3 轻审定位按阶段劈（闸）

- 原位置：改前 `:97-98`；挪走第二行括号里的复盘数字。
- 主文件现留的一句理由：spec 期严重发现压倒性是事实/符合类，实施期压倒性是对抗类。

原文：

⚠️ **轻审只有 1 个 agent，定位按阶段劈**：spec 期审的是文档，严重发现压倒性是事实/符合类；实施期审的是代码，压倒性是对抗类
（2026-09-21 复盘一周 4 仓约 30 次实战审核粗计：spec 期约 25+ 比 6-8，实施期约 15+ 比 3；#820 两路对照严重发现零交集）。

## R4 审核逐条核对 file:line（闸·执行时按老规矩）

- 原位置：改前 `:121`；挪走句末括号里的 2026-07-30 统计。
- 主文件现留的一句理由：实测这样能抓出作者自己没发现的事实错误。

原文：

- 要求逐条核对 spec 里的每个 `file:line` 引用和「现状是 X」断言——实测这样能抓出作者自己没发现的事实错误（2026-07-30 两份 spec 共 25 条发现，其中 4 条是 spec 作者写错的事实）

## R5 范围外对账不扩成质量意见（闸·执行时按老规矩）

- 原位置：改前 `:124`；挪走句末括号里的官方链接。
- 主文件现留的一句理由：审核 prompt 写狠了会反向逼实施方加防御层。

原文：

- **范围外对账只报「spec 改动面之外的变更」**，不扩展成质量意见——审核 prompt 写狠了会反向逼实施方加防御层（[Anthropic 官方明示的代价](https://code.claude.com/docs/en/best-practices)）

## R6 命名 = 锁（第 7 步）

- 原位置：改前 `:134`；挪走「git 强制」后括号里的并发实测。
- 主文件现留的一句理由：git 强制。

原文：

- **命名 = 锁**：分支和 worktree 目录同名 `issue-<N>`，纯号、无 slug、无前缀。同一 `.git` 里分支名唯一、已被检出的分支不许再检出——git 强制（2026-09-16 实测：5 进程并发抢同号，恰好 1 个开成，其余全被 fatal 拒）。**认领就是开 worktree**：开得成 = 没人做；被拒 = 有人在做。

## R7 别拿 issue open 当没人认领（第 7 步）

- 原位置：改前 `:135`；挪走 ⚠️ 句里括号中的 xhs-analysis #12 实例。
- 主文件现留的一句理由：open 同时表示待做和在做。

原文：

- **认领**：`git fetch origin --prune` 后 `git worktree add <wt根>/issue-<N> -b issue-<N> origin/main`（wt 根项目自定，如 `.claude/worktrees/`；从 origin/main 建，本地 main 可能落后）。想早知道可先 `git worktree list | grep issue-<N>`——可选，锁不靠它。⚠️ 别拿 issue `open` 当「没人认领」：open 同时表示待做和在做（xhs-analysis #12 实测：两个 agent 都据此判断「没人做」，双双做完浪费一份）——只信锁。

## R8 放锁时 squash 合并要换 -D（第 7 步）

- 原位置：改前 `:137`；挪走「换 `-D`」后的「2026-09-16 实测」。
- 主文件现留的一句理由：squash 合并时 `-d` 拒删，换 `-D`（操作指令本身不动）。

原文：

- **放锁**：PR 合并后 `git worktree remove <wt根>/issue-<N>` + `git branch -d issue-<N>`（`-d` 认的是 fetch 后的 origin/main，先 `git fetch origin`；远端 squash 合并时 `-d` 照样以 not fully merged 拒删——换 `-D`，2026-09-16 实测）。不放 = issue 重开时永远撞锁。

## R9 仓名只准当一次性证据（分工边界）

- 原位置：改前 `:164`、`:166`；挪走 house style 的 xhs-analysis 例子，与豁免名单删除始末那一句。
- 主文件现留的一句理由：仓自己改了规矩，没人会回来改这里，登记表只会越挂越旧。

原文：

本 skill 只管流程骨架。**项目专属的体例**（spec 放哪个目录、issue 标题格式、用哪些标签、正文节序）由该项目的指令文件（`AGENTS.md` / `CLAUDE.md`）或 agent 记忆承载——先查这两处有没有 house style（如 xhs-analysis 的 `issue-and-spec-house-style` 记忆条目），有就照它写。

⚠️ **本 skill 里出现的具体仓名，只准是「某条规矩的一次性证据」，不准攒成可追加的登记表**——仓自己改了规矩，没人会回来改这里，登记表只会越挂越旧。2026-09-16 那张逐仓豁免名单就是因此整张删掉的（来龙去脉见 `references/adoption-model.md`）。

## R10 体量护栏：为什么要预算、数字怎么来、红了怎么办

来源：#37 专项 spec `docs/specs/2026-09-26-skill-md-slim.md`（背景、调研表、D4 / D5）。现行预算数字**以 `scripts/check-docs.sh` 顶部为准**；下文出现的数字是定预算时的历史记录，改预算时改脚本、并在这里补一行历史。

**红了怎么办**：先别调预算。新增的案例 / 统计 / 来龙去脉挪进本档案、编新 R 号，规则旁只留一句理由 + 指针；同一条规则在多处重述的，合并成一处完整陈述，其余处改成按名指向。

**为什么要护栏**：
- 技能被调用时正文整份进上下文、之后不再重读；Claude Code 自动压缩后每个技能只重挂最近一次调用的前 5,000 token，越靠后的规则越先丢。所以「例外」「闸」前置，体量也要压。
- 增长（逐提交实测，各取当日末次提交）：09-10 1,386 → 09-16 4,712 → 09-21 6,064 → 09-24 10,233 → 09-26 10,497 字。09-21 至 09-26 六天净增 5,785 字，日均约 960——没有护栏，瘦完几天就涨回去。

**预算数字怎么来的**：spec 原定 8,000（目标约 7.5k、留约 500 余量）。实施时严格按 B 档（不删规则、不改判据语义，只挪案例、去重、缩非流程节、重排、收敛强调）瘦完，实测正文 8,586 字（补回原文细节、按实施期轻审修订后定稿 8,776），超出原预算；owner 2026-09-26 卡片改为 9,000（定稿余量约 220），不靠改写规则文字去凑数。字数口径 = frontmatter 结束行之后到文件末的全部字符，每行计换行（等价 `tail -n +5 SKILL.md | wc -m`，UTF-8）。

**警示符上限 3**：只留三条有记录在案的静默失败——⛔ 第 5 步回响（R1 反爬白改）、⚠️ 档位按份叠加（静默审浅）、⚠️ 别拿 open 当没人认领（R7 重复做）。其余警示去掉符号、保留句子；加粗每条 bullet / 段落至多一处。

**调研**（信源分档：官方一手 > 论文 > 其他；2026-09-26 打开核对）：

| 说法 | 出处 | 对本 spec 的含义 |
|---|---|---|
| 「Bloated CLAUDE.md files cause Claude to ignore your actual instructions!」；「If you emphasize many lines, none of them stands out.」 | [Claude Code best-practices](https://code.claude.com/docs/en/best-practices) | 体量和强调密度都要压 |
| 「Keep SKILL.md body under 500 lines」；「The context window is a public good.」；「Only add context Claude doesn't already have.」；「Keep references one level deep」 | [Agent Skills best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) | 细节进 references、只挂一层 |
| 「Providing context or motivation behind your instructions … can help Claude better understand your goals」；「Claude is smart enough to generalize from the explanation.」 | [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) | **理由不能挪走**：规则旁留一句「为什么」 |
| 「The fix is to dial back any aggressive language.」；skill-creator：「If you find yourself writing ALWAYS or NEVER in all caps … that's a yellow flag」 | 同上；[anthropics/skills skill-creator](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md) | 警示符收敛到少数几条 |
| IFScale 摘要：「bias towards earlier instructions」；Lost in the Middle 摘要：「performance is often highest when relevant information occurs at the beginning or end of the input context」 | [IFScale, arXiv 2507.11538](https://arxiv.org/abs/2507.11538)；[Lost in the Middle, arXiv 2307.03172](https://arxiv.org/abs/2307.03172) | 关键规则前置。坑：IFScale 测的是「keyword-inclusion instructions」，不是行为规则 |
