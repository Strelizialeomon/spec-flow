# spec：主文件瘦身——案例进依据档案、重复条款合并、关键规则前置、加体量护栏

- 日期：2026-09-26
- Issue：#37
- 状态：待审

## 背景：要解什么问题

### 现状（2026-09-26 实测，口径 = frontmatter 之后的正文，Python `len()` 字符数）

- `SKILL.md` 正文 **10,498 字 / 211 行**；最大一节「闸（两段共用）」3,535 字。
- 正文警示符 13 处（⚠️ 11、⛔ 2），另有 ⏰ 1 处；加粗 162 对。
- 增长（逐提交实测）：09-10 1,387 → 09-16 4,713 → 09-21 5,479 → 09-24 10,234 → 09-26 10,498。09-21 以来 5 天涨了约 5,000 字。

### 加载机制（官方文档原文，2026-09-26 已打开核对）

- Claude Code：技能被调用时正文整份进上下文，**之后不再重读**；自动压缩后「re-attaches the most recent invocation of each skill after the summary, keeping the first 5,000 tokens of each」（[skills 文档](https://code.claude.com/docs/en/skills)）。
- kimi：现役 kimi-code 源码把 SKILL.md 正文整份包进 `<skill-loaded>` 块注入；references 靠模型按需读（[kimi-code skills 文档](https://github.com/MoonshotAI/kimi-code/blob/main/docs/en/customization/skills.md)）。
- 含义：214 行离官方「500 行」线还远，**真正的约束是 token**。1.05 万中文字估算在 5k token 以上（**未实测**，本机无计数途径）——超出部分在长会话压缩后被截掉，而现在排在最后的恰是「段二·实施期」和「例外」（后者载着「不免闸」）。

### 互联网调研（信源分档：官方一手 > 论文 > 其他）

| 说法 | 出处 | 对本 spec 的含义 |
|---|---|---|
| 「Bloated CLAUDE.md files cause Claude to ignore your actual instructions!」；「If you emphasize many lines, none of them stands out.」 | [Claude Code best-practices](https://code.claude.com/docs/en/best-practices) | 体量和强调密度都要压 |
| 「Keep SKILL.md body under 500 lines」；「The context window is a public good.」；「Only add context Claude doesn't already have.」；「Keep references one level deep」 | [Agent Skills best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) | 细节进 references、只挂一层 |
| 「Providing context or motivation behind your instructions … can help Claude better understand your goals」；「Claude is smart enough to generalize from the explanation.」 | [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) | **理由不能挪走**：规则旁留一句「为什么」 |
| 「The fix is to dial back any aggressive language.」；skill-creator：全大写 ALWAYS/NEVER 是「yellow flag」 | 同上；[anthropics/skills skill-creator](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md) | 警示符收敛到少数几条 |
| 指令越多遵守率越低，靠前的指令更易被遵守（primacy） | [IFScale, arXiv 2507.11538](https://arxiv.org/abs/2507.11538)；[Lost in the Middle, arXiv 2307.03172](https://arxiv.org/abs/2307.03172) | 关键规则前置。坑：IFScale 测的是关键词纳入，不是行为规则 |

### 关键发现：只挪案例不够

逐段盘点（2026-09-26，按 R1–R9 挪出的原文逐段实测）：案例、统计、日期、来龙去脉合计 719 字，只占正文 7%；扣掉留下的一句理由和指针，净减更少。体量大头在**重复条款**（同一规则在 3–4 处重述）和**两个非流程节**（〈应用到项目〉975 字、〈参考〉807 字，前者与 `references/apply-to-project.md` 重叠）。

### owner 拍板（2026-09-26 对话，卡片记录）

瘦身力度选 **B 档**（挪案例 + 去重 + 两个非流程节缩成指针 + 关键规则前置，目标约 7.5k 字）；机制清单**全要**。C 档（条件细则外挪）不做，等实测 token 后另议。

## 机制清单（本 spec 新增的机制）

| # | 机制 | 解决什么 / 没有它会怎样 |
|---|---|---|
| 1 | **依据档案**：新建 `references/rationale.md`，收挪出的案例、统计、来龙去脉，按 R 编号；主文件规则旁只留一句理由 +「（依据：rationale Rn）」 | 案例有处可放、来历不丢 / 没有它：要么删掉丢来历，要么留在主文件继续胖 |
| 2 | **体量护栏**：本仓新建 `scripts/check-docs.sh`，正文超预算或警示符超限就红；闸节「文档检查入闸」的约定路径 ② 会在每次合并前自动跑它 | 瘦完不回涨 / 没有它：照 09-21 以来约 1,000 字 / 天的速度，几天就涨回 1 万字 |
| 3 | **关键规则前置**：章节重排，「例外」「闸」挪到总览之后 | 压缩只留前 5k token 时核心规则仍在 / 没有它：长会话后先丢实施期规矩和「不免闸」 |
| 4 | **强调收敛**：警示符 13 → ≤ 3，加粗 162 → ≤ 80 对 | 真正要紧的几条重新显眼 / 没有它：官方原话「处处强调等于没有强调」 |

## 改动面

B 档定义：**不删任何规则、不改任何判据语义**；只挪案例、合并重复、缩非流程节、重排、收敛强调。

### 1. 章节重排（机制 3）

新顺序：总览 → **例外** → **闸（两段共用）** → 工作区规矩 → 各步细则·段一 → 各步细则·段二 → 分工边界 → 应用到项目 → 参考（非流程）。

- 章节标题一字不改（`references/split-large-spec.md:71,73` 按名引「闸节」「第 7 步『认领与防撞车』」，锚点不废）。
- 跨节方位词改成按名引：`SKILL.md:10`「见下面闸节」、`:143`「见下面『工作区规矩』节」、`:214`「见上面『工作区规矩』」→ 去掉「上面 / 下面」。节内的「上方 / 下一条」不动。

### 2. 案例 / 统计 / 来龙去脉 → 依据档案（机制 1）

挪出内容**逐字**搬进 `references/rationale.md`，不改写；主文件那一句理由由实施方提炼。

| R | 原位置 | 挪走的 / 主文件留下的一句理由 |
|---|---|---|
| R1 | `:61-63` 第 5 步「为什么有这条」 | 挪：2026-09-11 反爬 CIDR→ASN 实例 / 留：只改判据那一句、别处不同步，照 spec 施工等于白改 |
| R2 | `:71` 第 6 步时机 | 挪：「owner 2026-09-01 钦定」+ 原理由全文 / 留：issue 锚 main 上 spec 的永久链接，spec 没定稿就开 issue 会两边互相引着改 |
| R3 | `:97-98` 轻审定位 | 挪：2026-09-21 复盘数字（25+ 比 6-8 等、#820）/ 留：spec 期严重发现以事实 / 符合类为主，实施期以对抗类为主 |
| R4 | `:121` 逐条核对 file:line | 挪：2026-07-30 两份 spec 25 条发现、4 条事实错误 / 留：能抓出作者自己没发现的事实错误 |
| R5 | `:124` 范围外对账 | 挪：Anthropic 官方链接 / 留：审核 prompt 写狠了会反向逼实施方加防御层 |
| R6 | `:134` 命名 = 锁 | 挪：2026-09-16 五进程并发实测 / 留：git 强制 |
| R7 | `:135` 别拿 open 当没人认领 | 挪：xhs-analysis #12 双双做完 / 留：open 同时表示待做和在做 |
| R8 | `:137` 放锁 | 挪：2026-09-16 squash 实测 / 留：squash 合并时 `-d` 拒删，换 `-D`（操作指令本身不动） |
| R9 | `:164,166` 分工边界 | 挪：xhs-analysis house style 例子、2026-09-16 豁免名单删除始末 / 留：仓自己改了规矩没人回来改这里，登记表只会越挂越旧 |
| R10 | （新增） | 本 spec 的调研表与预算依据——体量护栏报红时指向这里 |

档案头部写明：备忘录不是规程，`SKILL.md` 不依赖它；新增规则时案例写这里、主文件只留一句理由。

### 3. 去重：每组只留一处完整陈述

| 组 | 现在出现在 | 处理 |
|---|---|---|
| G1 长期授权与闸分家 | `:67`、`:107` 括注、`:118` | 留 `:118`；`:67` 缩成「长期授权，不用每次问（不管闸，见闸节）」；`:107` 括注删 |
| G2 代码 PR 不在授权内 | `:68`、`:148` | 留 `:148`（代码 PR 在段二合并）；删 `:68` |
| G3 例外只免方案期、不免闸 | `:111`、`:160`、`:214` | 留「例外」节（已前置到闸之前）；`:111` 删；`:160` 只留「豁免只免开 wt 一个动作，不免两段流程的其他环节」 |
| G4 两项不新增派发 | `:92`、`:100` | 留 `:92`；删 `:100` |
| G5 两段同一道闸、档位当场点 | 总览 `:27`、第 4 步 `:39`、`:78-79`、`:147` | 留总览一句 + 闸节开头；第 4 步缩成「spec PR 合并前过闸（见闸节），审的是 spec 本身」；`:147` 缩成「实施 PR 合并前过闸（见闸节）」 |

### 4. 两个非流程节缩成指针

- **〈应用到项目〉**（975 → 约 350 字）：留功能一句、触发、「不是流程步骤，没被要求别自作主张」、五步名称 + 「判定树、模板、幂等规则全在 `references/apply-to-project.md`，照它取，别现编」、已注册修饰词一行（`references/apply-to-project.md:168` 引它）、「旧副本 → 报告用户定夺，不自动删改」。「目标文件判定」三条细则只留 references 一份（见自定细节 D10）。
- **〈参考（非流程）〉**（807 → 约 400 字）：改成两列表「备忘录 | 何时读 / 约束」，6 份（含新增 rationale）。ADR「默认不启用、不自行引入、不主动追问」、文档生命周期「默认不启用、采用时只留指针」等约束**原样保留在表内**。

### 5. 强调收敛（机制 4）

- 警示符只留 3 处（见 D5），其余去掉符号、保留句子；⏰ 去掉。
- 加粗：每条 bullet / 段落至多一处，加在判据词上；步骤列表的步骤名可保留。

### 6. 体量护栏脚本（机制 2）

`scripts/check-docs.sh`（bash，内部用 python3 数 Unicode 字符）：

1. `SKILL.md` 正文字符数 ≤ 8,000，否则红，提示「新增的案例 / 统计 / 来龙去脉进 `references/rationale.md`，规则旁只留一句理由；依据见 rationale R10」。
2. 正文 ⚠️ + ⛔ 个数 ≤ 3，否则红。
3. `SKILL.md` 里出现的 `references/*.md` 路径都存在，否则红。

每项一行结果，末行「绿 / 红」，退出码 0 / 1。预算常量只写在脚本顶部一处。

### 7. 回响同步

- `references/apply-to-project.md:3`「`SKILL.md` 只留判定规则与指向」→「只留触发、五步骨架与指向」。
- `README.md` 目录加 `references/rationale.md`、`scripts/check-docs.sh` 两行。

## 回响自查（第 5 步硬规矩）

本改动不改任何判据 / 定义 / 常量 / 术语的语义，但动了章节位置和条文分布。已 grep 逐类核对：

- **跨文档按名引用**：`references/split-large-spec.md:71`（闸节）、`:73`（第 7 步「认领与防撞车」）→ 标题不改，不受影响；`references/adoption-model.md:32`（〈应用到项目〉功能）→ 不受影响；`references/apply-to-project.md:3` → 需改（见改动面 7）；`:168`（附加描述一行）→ 该行保留，不受影响。
- **按行号引用 `SKILL.md`**：`README.md`、`references/` 零命中；`docs/specs/` 五份历史 spec 有按行号引用——已实施的历史时点记录，按惯例不同步。
- **frontmatter description**：含「⛔ agent 不得自派审核」，不在正文口径内，不动。
- **落地物**：`scripts/check-docs.sh`、`references/rationale.md` 现在都不存在——本 spec 实施时新建，验收逐项核。

## 不做清单

- 不删规则、不改判据语义（B 档定义）；不做 C 档（文档检查入闸、撞锁恢复、审核执行细则外挪），等实测 token 后另议。
- 不改 frontmatter description——它每个会话都常驻，是另一笔账，另议。
- 不改 `references/` 既有备忘录正文（`apply-to-project.md:3` 一句指代除外）；不同步历史 spec。
- 不建 token 计数工具，护栏按字符数。
- 不给别的采纳仓加任何东西；护栏只管本仓。

## 验收标准

- [ ] `scripts/check-docs.sh` 存在、可执行、在实施后的主干上跑出**绿**。
- [ ] 变异三次各红一次：正文补到 8,001 字、多加一个 ⚠️、引一个不存在的 `references/x.md`。
- [ ] 正文 ≤ 8,000 字（目标约 7.5k），报前后字数；有 token 计数途径就报前后 token，没有就在 PR 写明未测。
- [ ] 章节顺序与改动面 1 一致；「例外」节起点在正文前 1,000 字内、「闸」节起点在前 1,500 字内；跨节「上面 / 下面」零命中。
- [ ] R1–R10 在档案里都有，R1–R9 为原文逐字搬入；主文件对应位置各有一句理由 + 依据指针。
- [ ] G1–G5 每组在主文件只剩一处完整陈述。
- [ ] 警示符 = 3 处且为 D5 所列；⏰ 零命中；加粗 ≤ 80 对。
- [ ] 实施 PR 附**规则对照表**：旧正文每条 bullet / 段落 → 新位置 / 并入哪组 / 挪到哪个 R。这是「语义不变」的核对依据。
- [ ] `references/apply-to-project.md:3`、`README.md` 目录已同步。

## 自定细节（本 spec 里替用户定掉的点，不同意就 veto）

| # | 自定细节 | 理由 |
|---|---|---|
| D1 | spec 落 `docs/specs/2026-09-26-skill-md-slim.md` | 仓体例 |
| D2 | worktree `~/code/spec-flow.worktrees/docs-slim-skill-spec`、分支 `docs/slim-skill-spec` | spec 期不占实施锁 `issue-37` |
| D3 | Issue 字段直接填 #37，合并后在 #37 回填永久链接、改动面、验收，不另开 issue | #37 已作立项占位先开，正文写明「spec 合并后在这里回填」 |
| D4 | 预算 8,000 字，字数口径同 #37（frontmatter 之后的 `len()`） | 目标约 7.5k，留约 500 余量；太松护栏形同虚设，太紧下一条规则就报红 |
| D5 | 警示符保留三处：⛔ 第 5 步回响、⚠️ 档位按份叠加、⚠️ 别拿 open 当没人认领 | 三条都有记录在案的静默失败（反爬白改、静默审浅、xhs #12 重复做） |
| D6 | 加粗 ≤ 80 对只验收一次、不进脚本 | 加粗计数误伤多（表头、步骤名），进脚本会逼人为凑数改排版 |
| D7 | 档案文件名 `rationale.md`，条目 R 编号，主文件指针写「（依据：rationale Rn）」 | 短；编号不随标题改动失效 |
| D8 | 挪出内容逐字搬，不改写 | 搬家时改写 = 同时丢信息又难核 |
| D9 | 章节标题一字不改 | 外部按名引用的锚点不废 |
| D10 | 〈应用到项目〉的「目标文件判定」三条只留 `references/apply-to-project.md` 一份 | 它们本来就在该文件 §一 / §三，且该功能强制先读模板；这是 B 档里**唯一一处规则条文离开主文件**，属跨文件去重 |
| D11 | 护栏第 3 项查 references 路径存在 | 本次加了一批指向档案的指针，指针断了来历就丢；可 veto |
| D12 | 脚本用 bash + python3，预算常量只写脚本顶部 | macOS / 常见 Linux 自带；数字只一处，不在 README 复述 |
| D13 | 去重保留处按改动面 3 表 | 保留在「规则语境最完整」的那一处 |

## 审核修订记录

（待过闸）
