# spec：spec-flow「应用到项目」——一句话把项目切成指针式采纳

- 日期：2026-09-22
- Issue：#14
- 状态：待实施（spec PR #13 已合并；spec 期审核档位 owner 先点「不审」，2026-09-22 后补轻审，8 条发现已全数修订，见文末「审核修订记录」）

## 背景：要解什么问题

多项目遵循 spec-flow 的现行做法是「逐字副本 + `@` 导入」，同步已成本烂账：

1. **副本会静默过期**——neuron-entry 的 `docs/spec-flow.md` 是 SKILL.md 的逐字副本，停在真身提交 `2c329cd`（2026-09-21），当天即落后；xhs-analysis 形制相同但更旧——停在 `98c2c43`（2026-09-16），且它的 CLAUDE.md 连「同步自哪个 hash」都没标。真身每改一次，N 个副本仓都要记得重拷（2026-09-22 逐仓 diff 实测）。
2. **只指向式已被验证可行**——taoxi-bd-workbench / taoxi_system / go_wechat_robot / finance-workspace / xhs-monitor 共 5 仓只在项目指令里放指针、不养副本，零同步事故；taoxi-bd-workbench 明写「本仓不放副本、不做任何同步机制」（2026-09-22 逐仓 grep 实测）。
3. **双工具公用仓的单源文件只能是 AGENTS.md**——kimi 原生读 AGENTS.md；Claude Code 2.1.277（2026-09-18）起在项目无 CLAUDE.md 时读 AGENTS.md，有 CLAUDE.md 则 AGENTS.md 被忽略、需在 CLAUDE.md 里加 `@AGENTS.md` 导入行（[官方 memory 文档](https://code.claude.com/docs/en/memory)的 `@` 导入机制 + [2.1.277 变更](https://devops.com/claude-code-adds-agents-md-fallback-cutting-instruction-file-sprawl/)）。taoxi-bd-workbench 的 CLAUDE.md 第 130 行（第三节）已在用这一招：`@AGENTS.md` 单独一行、不包反引号（该文件第 4 行只是叙述这件事，不是导入位）。

owner 需求原话（2026-09-22）：给 spec-flow 增加「应用到项目」功能，一行命令让项目的 md 文件变成引用 spec-flow 作为项目规矩的样子；ADR 是可选项，执行时允许附加描述（如「同时应用 adr」）。

形态拍板（2026-09-22 对话）：**不是 shell 脚本**（owner 否过脚本），是 skill 工作流——在目标项目的会话里对 agent 说一句话（「把 spec-flow 应用到本项目，同时启用 ADR」）或显式 `/skill:spec-flow 应用到项目 …` 触发。应用时要读项目现状做判定，脚本干不好。

ADR 疑虑的拍板（2026-09-22 对话）：owner 担心「外部没有指示让项目知道自己开了 ADR」。解法：ADR 入口节落在 AGENTS.md（两家工具每会话自动注入，非 agent 自觉读取），且入口节写成**动作式指令**（开工前搜 / 拍板后写），不是干声明。实证：finance-workspace 2026-09-22 启用 ADR 当天落 15 条决策记录（15:23 为最后一次写入），靠的就是 AGENTS.md 里的动作指令。

## 机制清单（本 spec 新增的机制）

| # | 机制 | 解决什么 | 没有它会怎样 |
|---|---|---|---|
| 1 | 「应用到项目」入口（SKILL.md 触发词 + 工作流节） | 一句话把项目切成指针式 | 回到手工搬副本、副本烂账 |
| 2 | 目标文件判定（指针本体只写 AGENTS.md；已有 CLAUDE.md 只补 `@AGENTS.md` 导入行） | 双工具公用仓写对文件 | 写进被 Claude 忽略的 AGENTS.md（有 CLAUDE.md 时），或造出第二份规矩正文 |
| 3 | 指针块模板（唯一真相源声明 + 远端 / 用法表 + 不放副本声明） | 各仓写同一形制 | 各写各的、规矩多源 |
| 4 | 附加描述机制（已注册修饰词 `adr`；未知描述当场问、不猜） | 「同时应用 adr」有标准动作 | ADR 应用靠手工，每次现编 |
| 5 | 旧副本 / 旧流程段检测（只报告，不自动删改） | 已养副本的仓不静默双轨 | 副本与指针两个「真相源」并存 |

## 改动面（四处）

### 改动 1：SKILL.md —— 触发词 + 「应用到项目」节

- frontmatter `description` 末尾追加触发词，语义覆盖：「把 spec-flow 应用到（本）项目 / 应用 spec-flow」。
- 正文新增一节 `## 应用到项目`，位置在「分工边界」之后、「参考（非流程）」之前（它是用户可触发功能，不是六步流程的步骤，也不是备忘录）。节内条文（最终措辞实施时定，语义不得少于以下各条）：
  - **触发**：用户说「把 spec-flow 应用到（本）项目」（可带附加描述，如「同时启用 ADR」），或显式 `/skill:spec-flow 应用到项目 …`。
  - **执行五步**：① 检测现状（指令文件有无、旧副本 / 旧流程段有无）→ ② 判目标文件 → ③ 写指针块 → ④ 解析附加描述 → ⑤ 报告结果（含检测到的旧物清单与处置建议）。
  - **目标文件判定**：指针本体只写 `AGENTS.md`（没有就新建）；项目已有 `CLAUDE.md` → 只补一行 `@AGENTS.md` 导入（已存在则不重复）；没有 `CLAUDE.md` → 不新建。
  - **附加描述**：已注册修饰词 `adr`（行为见改动 2）；不认识的描述当场问用户，不猜。
  - **旧副本 / 旧流程段**：检测到 `docs/spec-flow.md` 逐字副本、或指令文件里已有六步流程段落 → 报告给用户定夺，**不自动删改**。
  - 模板全文在 `references/apply-to-project.md`（相对路径引用，两工具都能解析）。

### 改动 2：`references/apply-to-project.md`（新文件）—— 模板与细则

内容要素（每块给出可直接套用的全文模板）：

1. **目标文件判定树**（改动 1 的展开，含幂等规则：已应用过的项目 = 校验指针节是否为最新形制，不重复追加）。
2. **指针块模板**：「流程规矩来自 spec-flow」声明 + 「唯一真相源、本文件不复述」+ 表格（远端真身 `https://github.com/Strelizialeomon/spec-flow`、本机用户级 skill、用法 = 开工前调 skill / 未装 skill 的机器直接读远端 SKILL.md）+「不放副本、不做同步机制」声明（形制仿 taoxi-bd-workbench，本地路径行按本机实际填）。
3. **CLAUDE.md 导入行**：`@AGENTS.md` 单独一行、不包代码块（neuron-entry / xhs-analysis 的既有教训：包进反引号会静默失效）。
4. **ADR 入口节模板**（修饰词 `adr` 时写入 AGENTS.md）：启用声明（日期应用时填）+ 规则页位置 + 三条动作指令——开工前按业务词 / 表名 / 接口名 / 组件名搜 `docs/decisions/` 里「生效中」的 ADR；用户拍板命中写入条件时，继续设计前新增 / 取代 ADR 并与 spec 放同一文档 PR；spec 只列生效 ADR 链接、不复制正文。
5. **`docs/decisions/README.md` 规则页骨架**（修饰词 `adr` 时创建，连同 `docs/decisions/` 目录）：启用声明 + 载体分工一句话 + 什么时候写 / 命名与状态 / 取代流程**只链 ADR 备忘录**（`references/adr-decision-records.md`，远端链接）不复述 + 默认命名（`YYYY-MM-DD-<slug>.md` / `ADR-YYYYMMDD-<slug>` / 状态：生效中 / 已被取代）。按 ADR 备忘录§三最小版；finance-workspace 的重度演化版不当模板。
6. **附加描述处理规则**：已注册修饰词清单（当前仅 `adr`）；未知描述当场问；空描述 = 只应用流程指针。`adr` 的说法变体（「同时启用 ADR」「加上 adr」等）按语义判定。
7. **旧副本检测口径**：`docs/spec-flow.md` 存在且内容与 SKILL.md 高相似（实现时 diff / grep 判）；或指令文件已有「六步流程」段落。处置一律为「报告 + 用户定夺」。

### 改动 3：`references/adoption-model.md` —— 演进记录

加一节「2026-09-22 演进」：「严格遵循的项目」层的标准动作从「同步一份 + 指向真身」演进为「**应用到项目**功能产出的只指向式」；存量副本仓（neuron-entry / xhs-analysis）按 owner 2026-09-22 拍板**维持现状、不追改**；**旧裁决就地标注取代**——第 9 行层描述（「同步一份 + 指向真身」）与 §历史教训标题（「为什么副本必须『同步 + 指向』」）各加「已被 2026-09-22 演进取代」注（仿第 17 行既有写法），不许留下两个互相打架的真相源；三层模型的**分类本身**（哪三层、各自定义）不改写。

### 改动 4：`README.md` —— 目录节补一行

`references/apply-to-project.md` 登记进目录清单（一句话：应用到项目的模板与细则）。

## 不做清单

- 不动 neuron-entry / xhs-analysis 的存量副本（owner 2026-09-22 拍板维持现状）。
- 不做 shell 脚本 / CLI 命令形态（owner 否过脚本；应用动作要读项目现状做判定）。
- 不做 CI / 检查脚本等硬闸——本功能是软约束定位，owner 已知并接受。
- 不自动删除 / 改写项目里已有的流程段落或副本（检测后只报告）。
- ADR 重型机制不预装——按 ADR 备忘录§八原文四项：开工 / 拍板 / 收尾三时点 Gate、spec / issue 固定元数据、ADR 结构与取代关系检查脚本、跨仓库与平台的固定消费者反查。
- 不登记「哪些仓应用过」的名单（SKILL.md 既有规矩：不攒登记表）。
- 本 spec 不含六步流程本身的任何改动。

## 验收标准

- [ ] SKILL.md 的 description 含「应用到项目」触发词；正文有「应用到项目」节，且覆盖改动 1 列出的全部条文语义，并指到 `references/apply-to-project.md` 取模板。
- [ ] `references/apply-to-project.md` 含改动 2 的 7 项要素，模板可直接套用。
- [ ] `references/adoption-model.md` 含「2026-09-22 演进」节；第 9 行层描述与 §历史教训标题均已标「已被取代」；三层分类本身未改写。
- [ ] README.md 目录节含 `references/apply-to-project.md` 一行。
- [ ] dogfood 实测（实施期，临时假仓）：① 无任何指令文件的仓 → 新建 AGENTS.md 含指针块；② 只有 CLAUDE.md 的仓 → CLAUDE.md 只补 `@AGENTS.md` 一行、指针在新建 AGENTS.md；③ 已有 `docs/spec-flow.md` 副本的仓 → 只报告不改动；④ 带「同时启用 ADR」→ AGENTS.md 含动作式 ADR 入口节 + 生成 `docs/decisions/README.md` 骨架；⑤ 重复应用 → 幂等，不重复追加。
- [ ] 回响检查（第 5 步硬规矩）：改动 1~4 的**每个被改文件**逐一核对落点——跨文档引用（SKILL.md 引「参考」「adoption-model」等处）+ 该文件**自身**受本次改动影响的旧表述；旧裁决与新裁决打架处必须标「已被取代」，不许双源。范围不止 SKILL.md。

## 自定细节（本 spec 里替用户定掉的点，不同意就 veto）

| # | 自定细节 | 理由 |
|---|---|---|
| D1 | spec 落 `docs/specs/2026-09-22-apply-to-project.md` | 仓体例（2026-09-22 design-control-gates spec 立的 D1） |
| D2 | worktree 根 `~/code/spec-flow.worktrees/`、分支 `issue-14` | SKILL.md「认领与防撞车」：**有 issue 号**的活分支名 = 防撞锁 = `issue-<N>`（纯号、无 slug、无前缀），本 spec 头部已回填 Issue #14。原写 `docs/apply-to-project`（引的是「无 issue 号的活」那半条）：既丢锁、又撞 origin 上未合并的旧同名分支 |
| D3 | 模板全文放 `references/apply-to-project.md`，SKILL.md 只留判定规则与指向 | SKILL.md 已 143 行，~50 行模板会稀释流程正文；`references/` 是既有细则位 |
| D4 | SKILL.md 新节位置：「分工边界」后、「参考（非流程）」前 | 它是用户可触发功能，层级高于备忘录；不进六步正文（不是流程步骤） |
| D5 | 指针块表格列 = 远端真身 / 本机 skill / 用法 | 仿 taoxi-bd-workbench 已验证形制；本地路径行按应用时本机实际填 |
| D6 | ADR 入口节三条动作：开工前搜 / 拍板命中先写 / spec 只链不抄 | 仿 finance-workspace AGENTS.md 当日跑通的形制，砍到最小 |
| D7 | 规则页骨架只含：启用声明、载体分工一句话、命名默认、其余全链备忘录 | ADR 备忘录§三钦定最小版；细则双源会重演副本烂账 |
| D8 | 「旧副本」判定用高相似度（diff / grep），不做人肉逐字比对 | 可操作的判定口径；误报代价低（只报告） |
| D9 | 指针块「用法」行取值 = 开工前调 skill / 未装 skill 的机器直接读远端 SKILL.md | 目标机器装没装 skill，应用时判不出来，两条并列写死最稳（原只活在改动 2 项 2 正文里，未进本表） |

## 审核修订记录

2026-09-22 spec 期轻审（1 个独立 agent，规格符合性 + 两张清单完整性），8 条发现全数修订：

| # | 严重度 | 发现 | 处置 |
|---|---|---|---|
| 1 | 严重 | D2 分支名 `docs/apply-to-project` 与 SKILL.md「命名 = 锁」打架，且撞 origin 未合并的旧同名分支（照做会丢防撞锁 + push 被拒） | D2 改 `issue-14`，理由重写 |
| 2 | 中 | 背景 3 称 taoxi-bd-workbench 的 `@AGENTS.md` 在 CLAUDE.md 第 4 行，实为第 130 行 | 改正行号，并点明第 4 行只是叙述 |
| 3 | 中 | 改动 3 只加演进节，adoption-model.md 自身旧裁决未标取代；回响检查范围只写了 SKILL.md | 改动 3 加「旧裁决就地标注取代」；验收第 3 条与回响检查条同步扩到「每个被改文件」 |
| 4 | 轻 | 「xhs-analysis 同形制」若读作同停点则不实——它停在 `98c2c43`（2026-09-16） | 改为写明两仓各自停点与 hash |
| 5 | 轻 | 「finance-workspace 当天落 10 条」已过时，实为 15 条 | 改 15 条 |
| 6 | 轻 | 不做清单把「模板生成器」挂在 ADR 备忘录§八，§八无此项 | 照 §八四项原文重列 |
| 7 | 轻 | 自定细节漏列「用法」行取值（D5 只定了列名） | 补 D9 |
| 8 | 轻 | 头部状态行的审核档位记录与本次实况对不上 | 回填「先点不审、后补轻审」 |
