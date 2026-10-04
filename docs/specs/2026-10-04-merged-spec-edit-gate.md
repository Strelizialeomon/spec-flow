# spec：改已合并 spec 的正文前先问用户（新开一份 / 改旧的）

- 日期：2026-10-04
- Issue：#51
- 状态：待实施

## 背景：要解什么问题

项目启用 ADR 之后，新的决定有了自己的落点；但新需求来了，agent 仍然习惯把它写成「旧 spec 的修订」：在一份早已合并、甚至已经实施过的 spec 里改条款、全文同步引用。spec 越改越长，原来批准的是什么、后来改了什么，混在一起分不开。

### 现状（2026-10-04 实测）

- **jasmine-lottery 全仓只有 1 份 spec**（`docs/superpowers/specs/2026-09-30-lottery-h5-design.md`）：09-30 建档时 448 行，现在 762 行。`git log --follow` 共 17 个提交改过它；09-30 23:20 回填首个 Issue 号（#2）之后，又有 15 个提交改它，其中只有 1 个是纯元信息回填（`97ef77b` 补子单号），其余 14 个都改了正文，包括至少 4 个实施 PR：`8565544`（Go 后端）改写了并发标记规则；`34364f7`（3D 模型第四版，PR #17 自述「属于实施工单 #2 的一部分」）与 `60cb1d8`（3D 盲盒第五版）都改写了「落地物现状」；`a0c62f7`（端到端收口）加了一行指向新 ADR 的说明。另有 `fa47790`（PR #4，feat）也改了正文（若算模型交付则共 5 个）。
- **2026-10-04 会话**：用户拍板「6 位纯数字兑换码」「后台 Semi 默认主题」等新需求后，agent 回报「正在写需求文档的修订，同步各处引用『8 位码』和后台外观的地方」——准备直接改那份旧 spec。用户打断：「我们这是新需求，写新的 spec 和 adr，别老是改以前的 spec，越改越乱」。
- **spec-flow 现状**：「定稿后冻结、新需求另起 spec」只写在可选备忘录 `references/documentation-lifecycle.md` §二；jasmine-lottery 的 `AGENTS.md` 只启用了 ADR，没启用这份备忘录，所以这条对它不生效。主文件第 5 步硬规矩「改一条判据，必须全文搜所有落点逐一同步」没有限定「只在合并前」——会话里「同步各处引用」正是照这条在做。

### 调研（2026-10-04 打开核对）

| 说法 | 出处 | 对本 spec 的含义 |
|---|---|---|
| 「If a decision is reversed, we will keep the old one around, but mark it as superseded.」 | [Nygard 2011](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)（ADR 的提出者） | ADR 侧已照此执行；spec 侧缺同类约束 |
| 「once accepted, RFCs should not be substantially changed … More substantial changes should be new RFCs, with a note added to the original RFC.」 | [Rust RFC 仓库 README](https://github.com/rust-lang/rfcs) | 定稿后大改 = 新开一份 |
| 「Once resolution is reached, a PEP is considered a historical document rather than a living specification.」；新 PEP 带 `Replaces`、旧 PEP 带 `Superseded-By` | [PEP 1](https://peps.python.org/pep-0001/) | 同上；现状另找地方写 |
| 更新已有变更 vs 新开：「Intent fundamentally changed」「Original change can be marked "done" standalone」→ 新开 | [OpenSpec workflows.md](https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md)「When to Update vs Start Fresh」 | 可作卡上推荐项的参考判据（主文件不写，见 D4） |
| 反例：「Change a core requirement in the PRD, and affected implementation plans update automatically」——就地改、再重新生成 | [GitHub Spec Kit spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md) | 就地改的前提是 spec 能自动重新生成实现；spec-flow 没有这一层 |

坑：spec 冻结后，「系统现在是什么样」要顺着几份 spec 读。OpenSpec 另设「当前状态」spec、PEP 把现状写进参考手册来解；spec-flow 现有的答案是 ADR（决定）+ 可选的现状文档（事实，`documentation-lifecycle.md` §四）。本 spec 不解这个问题。

### owner 拍板（2026-10-04 对话，卡片记录）

- agent 先提了三个机制（开工先分流 / 冻结点 / 新旧两份互指），owner 否：「我觉得没那么麻烦，加一个闸口，如果 agent 拿不准到底是改老的 spec 还是新出 spec 就问用户，不要自作主张就好了」。
- 触发条件：agent 指出「拿不准才问」拦不住这次的情况（当时 agent 并没有拿不准），owner 选客观版「**改已合并 spec 正文就问**」。
- 主文件字数：闸放进去会超 9,000 上限。owner 提「可以考虑主体正文总体重构了」；顺序选「**先落闸，重构另开**」——本 spec 把上限临时放到 9,200，主文件重构另起 spec，届时收回。

## 机制清单（本 spec 新增的机制）

| # | 机制 | 解决什么 / 没有它会怎样 |
|---|---|---|
| 1 | **已合并 spec 动正文先问**：改一份已合并 spec 的正文前，用选择卡问用户「新开一份 spec / 改旧的」，agent 不自判 | 新需求不再被静默塞进旧 spec / 没有它：agent 照第 5 步「全文同步」去改已定稿的 spec，越改越乱 |

上限临时调到 9,200 是参数调整，不是新机制。

## 规则正文（实施时照此写进 `SKILL.md`）

```markdown
## 已合并的 spec：动正文先问

改已合并 spec 的正文前（新需求、实施中发现写错都算），用选择卡问用户「新开一份 spec / 改旧的」，不自判、没点不动笔。免问只有两类：闸节「交付物口径」列的无新内容机械变更（回填号、状态行、勾验收），和往末尾「审核修订记录」追加；归边不明照问。理由：定稿 spec 被新需求反复改写会越改越乱（依据：rationale R12）。
```

## 改动面

本 spec 里 `:N` 均指改前 `SKILL.md`（main `739af1b`）的全文行号，含 frontmatter。

### 1. `SKILL.md`

- 在 `:33`（「不开 wt」那行）之后、`:35`「## 闸（两段共用）」之前，插入上方「规则正文」整节（前后各留一空行）。
- 其余不动。字数：插入后就地模拟实测 9,157（余量 43，以 `scripts/check-docs.sh` 实测为准）；警示符不变，仍为 3。

### 2. `scripts/check-docs.sh`

- `BUDGET_CHARS=9000` → `9200`，行尾注释补「临时，主文件重构 spec 收回」。

### 3. `references/rationale.md`

- 新增 **R12「已合并 spec 动正文先问」**：来源指本 spec；主文件落点；现状证据（jasmine-lottery 总 spec 的行数与提交数、2026-10-04 会话原话）；调研摘要（一句话 + 指回本 spec 调研表）；owner 拍板；为什么「没点不动笔」而不是闸卡那种「没点按不审走」（D3）。
- **R10** 中段「预算数字怎么来的」段（在调研表之前，非 R10 末尾）补一句历史：2026-10-04 owner 卡片临时放到 9,200，待主文件重构 spec 收回。

### 4. `references/documentation-lifecycle.md`

- §二「基线后的处理：」改为「基线后的处理（动正文前先照主干〈已合并的 spec：动正文先问〉问用户，下列分流作卡上推荐项的依据；主干以「已合并」为准，比本节的基线早一步）：」。分流规则本身不动。

## 回响自查（第 5 步硬规矩）

| 落点 | 结论 |
|---|---|
| 机制 / 原理节 | 只有主文件新节一处；理由与案例进 R12 |
| 实现 / 数据源节 | 无脚本新增；`check-docs.sh` 只改预算常量 |
| 实施步骤 | 改动面 1–4 |
| 验收标准 | 新节每个要素、预算、R12 / R10、备忘录衔接句各有可验项，见下 |
| 跨文档引用 | `documentation-lifecycle.md` §二 加衔接句；`adr-decision-records.md` §三第 5 条与 §七第 4 条已写「不回写历史 spec」，与本闸一致，不改；`README.md` 不列规则，不改 |
| 历史记录节 | 旧 spec（含 `2026-09-26-skill-md-slim.md` 里 9,000 的预算记录）不回改；预算历史写进 R10 |

## 不做清单

- 不加「开工先分流」「冻结点」「新旧两份互指」三个机制：owner 否了，只要一道闸。
- 不加机器检查（PR 改了已合并 spec 正文就报红）。
- 不重构主文件、不删其他段落腾字数：另起 spec。
- 不改 jasmine-lottery 的任何文件，不回改它那份总 spec。
- 不改 ADR 备忘录。

## 验收标准

- [ ] 1. 实施分支上跑 `scripts/check-docs.sh` 全绿：正文 ≤ 9,200、警示符仍为 3、references 路径全部存在。
- [ ] 2. `SKILL.md` 有「## 已合并的 spec：动正文先问」一节，位于「## 例外」与「## 闸（两段共用）」之间，含：触发是已合并 spec 的正文（新需求、实施中发现写错都算）；选择卡两选项「新开一份 spec / 改旧的」；不自判；没点不动笔；两类免问（机械变更、审核修订记录追加）；归边不明照问；依据 rationale R12。
- [ ] 3. `scripts/check-docs.sh` 的 `BUDGET_CHARS` 为 9200，注释写明临时、待重构收回；R10 有 2026-10-04 这一行历史。
- [ ] 4. `references/rationale.md` 有 R12，含现状证据、调研摘要、owner 拍板、「没点不动笔」的理由。
- [ ] 5. `references/documentation-lifecycle.md` §二「基线后的处理」带衔接句，分流各条原文不变。

## 自定细节（本 spec 里替用户定掉的点，不同意就 veto）

| # | 自定细节 | 理由 |
|---|---|---|
| D1 | 新节落在「例外」之后、「闸」之前，独立成节 | R10：越靠前，自动压缩后越不容易丢；独立成节好 grep，段一、段二都能撞上 |
| D2 | 「已合并」= spec 所在 PR 已合入主干；PR 还没合时的修订照第 5 步走，不问 | 合并前本来就在评审修订期 |
| D3 | 没点 = 不动旧 spec 正文（不像闸卡那样「没点按不审走」） | 闸卡的两个结果里「不审」是安全默认；这张卡两个选项都会产出文件，安全默认只能是先不动 |
| D4 | 卡上照全局规矩给推荐项，主文件不写推荐判据；OpenSpec「原需求不带这次改动能否单独算做完」只记在 R12 当参考 | owner 否了「开工先分流」机制，不把它换个名字塞回主文件 |
| D5 | 免问的第二类「往末尾审核修订记录追加」 | 本仓实施后会往 spec 末尾回填实施期审核记录（如 `6f2978e`），这是记账、不是改需求；不免的话每次回填都要多点一次卡 |
| D6 | 预算 9,200 只是临时值，注释和 R10 都写「待重构收回」 | owner 选「先落闸，重构另开」 |
| D7 | 新依据编号 R12 | 接 R11 |
| D8 | spec 文件名 `2026-10-04-merged-spec-edit-gate.md` | 沿用 `docs/specs/` 的日期前缀体例 |

## 审核修订记录

2026-10-04 spec 期**轻审**（1 个只读审核 agent，用户点档「轻审」派出），发现 2 条（严重 0 / 中 1 / 轻 1），同日全数修订；结论原文见 PR #50 评论。

| # | 严重度 | 发现 | 处置 |
|---|---|---|---|
| 1 | 中 | 现状节「3 个实施 PR」计数与实测不符：应至少 4 个，漏 `34364f7`（PR #17，PR 正文自述「属于实施工单 #2 的一部分」）；`fa47790`（PR #4）亦改了正文，若算模型交付则共 5 个 | 改「至少 4 个」并补 `34364f7`，`fa47790` 以附注列出 |
| 2 | 轻 | 「R10 末尾『预算数字怎么来的』段」位置描述不准：该段在 R10 中段（其后还有警示符上限段与调研表） | 位置描述改为「R10 中段、调研表之前」 |

2026-10-04 实施期**轻审**（PR #53，1 个只读审核 agent，用户点档「轻审」派出），发现 3 条（严重 0 / 中 1 / 轻 2），修订卡用户点「改」，同日全数修订；结论原文见 PR #53 评论。本节之前的正文是合并时的原样，未回改。

| # | 严重度 | 发现 | 处置 |
|---|---|---|---|
| 1 | 中 | R12 现状首条「1 份 spec / 17 / 15 / 14」已被同日 20:23 jasmine-lottery PR #35（新开第二份 spec、改旧 spec 正文 1 行）打破，今天复现为 18 / 16 / 15 | R12 加一句时间限定（PR #35 之前的快照）并写明此后数字；本 spec 现状节同组数字是历史快照，不回改 |
| 2 | 轻 | 新节括号「（回填号、状态行、勾验收）」与闸节「回填 issue 号 / 状态行 / 索引等」列举对不上 | `SKILL.md` 改为「（回填号、状态行、索引、勾验收等）」——与本 spec「规则正文」差这几个字，以 `SKILL.md` 为准 |
| 3 | 轻 | R12「只写在 lifecycle §二」不严：ADR 备忘录 §三第 5 条、§七第 4 条也有「不回写历史 spec」 | R12 补半句：那两条管采用 ADR / 改决定场景，管不到新需求 |
