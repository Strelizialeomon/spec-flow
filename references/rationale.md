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

## R4 审核逐条核对 file:line（闸·gate-details §一）

- 原位置：改前 `:121`；挪走句末括号里的 2026-07-30 统计。
- 主文件现留的一句理由：实测这样能抓出作者自己没发现的事实错误。

原文：

- 要求逐条核对 spec 里的每个 `file:line` 引用和「现状是 X」断言——实测这样能抓出作者自己没发现的事实错误（2026-07-30 两份 spec 共 25 条发现，其中 4 条是 spec 作者写错的事实）

## R5 范围外对账不扩成质量意见（闸·gate-details §一）

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

## R9 仓名只准当一次性证据（本仓 AGENTS.md）

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

**预算数字怎么来的**：spec 原定 8,000（目标约 7.5k、留约 500 余量）。实施时严格按 B 档（不删规则、不改判据语义，只挪案例、去重、缩非流程节、重排、收敛强调）瘦完，实测正文 8,586 字（补回原文细节、按实施期轻审修订后定稿 8,776），超出原预算；owner 2026-09-26 卡片改为 9,000（定稿余量约 220），不靠改写规则文字去凑数。2026-10-04 加〈已合并的 spec：动正文先问〉一节会超 9,000，owner 卡片选「先落闸，重构另开」：临时放到 9,200（插入后 9,157），待主文件重构 spec 收回（#51 专项 spec `docs/specs/2026-10-04-merged-spec-edit-gate.md`）。同日 #56 重构：用 `claude -p` 差值法实测正文 9,161 字 = 8,118 token，压缩后只保留前 5,000 token，截断点约在第 5 步「改表格」那段，其后的第 6 步、段二、参考目录在长会话里会丢；重构后正文 4,168 字 / 3,585 token，预算改为 5,000 字（约 4,300 token，每字 0.86 token），离截断线留约 700 token（#56 专项 spec `docs/specs/2026-10-04-skill-md-restructure.md`）。字数口径 = frontmatter 结束行之后到文件末的全部字符，每行计换行（等价 `tail -n +5 SKILL.md | wc -m`，UTF-8）。

**警示符上限 3**：只留三条有记录在案的静默失败——⛔ 第 5 步回响（R1 反爬白改）、⚠️ 档位按份叠加（静默审浅）、⚠️ 别拿 open 当没人认领（R7 重复做）。其余警示去掉符号、保留句子；加粗每条 bullet / 段落至多一处。

**调研**（信源分档：官方一手 > 论文 > 其他；2026-09-26 打开核对）：

| 说法 | 出处 | 对本 spec 的含义 |
|---|---|---|
| 「Bloated CLAUDE.md files cause Claude to ignore your actual instructions!」；「If you emphasize many lines, none of them stands out.」 | [Claude Code best-practices](https://code.claude.com/docs/en/best-practices) | 体量和强调密度都要压 |
| 「Keep SKILL.md body under 500 lines」；「The context window is a public good.」；「Only add context Claude doesn't already have.」；「Keep references one level deep」 | [Agent Skills best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) | 细节进 references、只挂一层 |
| 「Providing context or motivation behind your instructions … can help Claude better understand your goals」；「Claude is smart enough to generalize from the explanation.」 | [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) | **理由不能挪走**：规则旁留一句「为什么」 |
| 「The fix is to dial back any aggressive language.」；skill-creator：「If you find yourself writing ALWAYS or NEVER in all caps … that's a yellow flag」 | 同上；[anthropics/skills skill-creator](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md) | 警示符收敛到少数几条 |
| IFScale 摘要：「bias towards earlier instructions」；Lost in the Middle 摘要：「performance is often highest when relevant information occurs at the beginning or end of the input context」 | [IFScale, arXiv 2507.11538](https://arxiv.org/abs/2507.11538)；[Lost in the Middle, arXiv 2307.03172](https://arxiv.org/abs/2307.03172) | 关键规则前置。坑：IFScale 测的是「keyword-inclusion instructions」，不是行为规则 |

## R11 审核结论贴 PR 评论、改不改问用户（闸·gate-details §一）

来源：#41 专项 spec `docs/specs/2026-09-28-review-comment-and-revision-card.md`（背景、D4、D5、D8、D10、D11、D14）。

- 主文件落点：闸节末条（贴评论 + 修订卡）、`references/gate-details.md` §一；豁免总表·合并卡行（长期授权不免修订卡）。2026-10-04 #56 重构前在闸节「执行时按老规矩」「长期授权与闸分家」两条。

**现状（2026-09-28 实测）**：
- 审核结论落点不一：#34、#35 贴在 PR 评论（「审核留档」）；#37 spec 期贴在 issue 评论；#37 实施期（PR #39）14 条没贴成 PR 评论，只有 PR 正文一节摘要、issue #37 回填评论一句、仓内 spec 末尾的逐条处置表。当时 `SKILL.md` 没有一句规定审核结论原文落哪。
- 审完默认自动全改：#37 实施期（PR #39）14 条由 agent 当日自行全数处置（PR 正文「全部成立、已修」），经 owner 卡片确认的只有 1 处；spec 期 16 条是 owner 明示交 agent 逐条判断修复（issue #37 审核留档「处置：待定」那条），不算默认，经卡片确认的同样只有 1 处。
- 第 5 步旧措辞「按需要修订 → 开 PR 并合并」读起来是审完才开 PR；实际 #38 在 09:59 UTC 开 PR、10:15 UTC 才提交轻审修订——一直是先开 PR 再审。

**owner 拍板（2026-09-28 对话，卡片记录）**：三条机制全要；修订卡只问一次整体「改 / 不改」，不逐条标推荐；评论审完立即贴一次，处置照旧记进 spec 末尾「审核修订记录」表，不再回帖。

**为什么「原样」**：不改写、不删条、不降严重度——主 agent 转述会过滤或弱化对自己不利的发现。可加一行头（日期 · 档位 · agent 数 · 严重 / 一般 / 提示计数），沿用 #35 的「审核留档」头。「审核结论」含变异结果（重审 + 变异档），一轮一条评论、多个 agent 分节。

**为什么零发现不摆卡、「不审」档两样都免**：零发现没东西可改，摆卡只会让「没答不合并」把一张空卡变成合并的卡点；评论照贴（写「0 条发现」），证明审过。「不审」档没有审核 subagent，也就没有审核结论可贴、可问。

**为什么没答不合并，却不和闸卡「没点 → 不审、不阻塞」矛盾**：两张卡问的东西不一样。闸卡问的是花不花审核成本，不审是正当选择；修订卡问的是已知问题留不留，没答就合并 = 带着已知问题静默进主干。同理，「只含 spec / 文档的 PR 合并长期授权」只管合并动作要不要再问，不替用户回答修订卡。

## R12 已合并 spec 动正文先问（卡片总表·改旧 spec 卡）

来源：#51 专项 spec `docs/specs/2026-10-04-merged-spec-edit-gate.md`（背景、调研表、D2–D5）。

- 主文件落点：卡片总表·改旧 spec 卡行及表下理由句、豁免总表·改旧 spec 卡行。2026-10-04 #56 重构前是「例外」与「闸」之间的〈已合并的 spec：动正文先问〉一节。

**现状（2026-10-04 实测）**：
- 以下数字是同日 20:23 jasmine-lottery PR #35 新开第二份 spec 之前的快照；PR #35 也改了旧 spec 正文 1 行（加「已被 ADR 取代」注），此后为 18 / 16 / 15。
- jasmine-lottery 全仓只有 1 份 spec，09-30 建档 448 行，至 10-04 长到 762 行，`git log --follow` 共 17 个提交改过它；回填首个 Issue 号之后又有 15 个提交改它，只有 1 个是纯元信息回填，其余 14 个改了正文，其中至少 4 个是实施 PR。
- 2026-10-04 会话：新需求拍板后，agent 回报「正在写需求文档的修订，同步各处引用『8 位码』和后台外观的地方」，准备直接改那份旧 spec；用户打断：「我们这是新需求，写新的 spec 和 adr，别老是改以前的 spec，越改越乱」。
- 当时「定稿冻结、新需求另起 spec」只写在可选的 `references/documentation-lifecycle.md` §二，该项目只启用了 ADR，这条对它不生效（ADR 备忘录 §三第 5 条、§七第 4 条的「不回写历史 spec」管的是采用 ADR、改决定的场景，管不到新需求）；第 5 步「全文同步所有落点」没限定只在合并前，会话里「同步各处引用」正是照它在做。

**调研**（2026-10-04 打开核对，原文与链接见专项 spec 调研表）：ADR 提出者 Nygard、Rust RFC、Python PEP 1 都是「定稿后不大改，大改新开一份、新旧互相标注」；OpenSpec 的「更新已有变更 vs 新开」判据可作卡上推荐项参考——「Intent fundamentally changed」「Original change can be marked "done" standalone」→ 新开；反例 Spec Kit 就地改 spec，前提是能自动重新生成实现，spec-flow 没有这一层。

**owner 拍板（2026-10-04 对话，卡片记录）**：agent 先提三个机制（开工先分流 / 冻结点 / 新旧两份互指），owner 否：「我觉得没那么麻烦，加一个闸口，如果 agent 拿不准到底是改老的 spec 还是新出 spec 就问用户，不要自作主张就好了」。agent 指出「拿不准才问」拦不住当次情况（那次 agent 并没有拿不准），owner 选客观触发「改已合并 spec 正文就问」。

**为什么「没点不动笔」，而不是闸卡那种「没点按不审走」**：闸卡的两个结果里「不审」是安全默认；这张卡两个选项（新开 / 改旧）都会产出文件，安全默认只能是先不动。

**为什么免问「往末尾审核修订记录追加」**：实施后往 spec 末尾回填实施期审核记录是记账、不是改需求；不免的话每次回填都要多点一次卡。

**为什么主文件不写推荐判据**：owner 否了「开工先分流」，卡上照全局规矩给推荐即可，不把那个机制换个名字塞回主文件。

## R13 主文件重构：卡片总表、豁免总表、细则用到才读

来源：#56 专项 spec `docs/specs/2026-10-04-skill-md-restructure.md`（现状、调研表、行为变更清单、改前 → 改后对照、D1–D13）。

- 主文件落点：「主线」段、「卡片总表」「豁免总表」两节、「各步要点」节、参考表前三行；细则在 `references/gate-details.md`、`references/worktree-lock.md`、`references/spec-revision-sync.md`；维护规矩在本仓 `AGENTS.md`。

**现状（2026-10-04 实测，重构前 main `cf0bf80`）**：
- 体量：正文 9,161 字 / 8,118 token，压缩后后约 38% 被截（见 R10）。
- 叠床架屋：要用户点的卡有 5 种，没点时怎么办散在 5 处、说法不一；「免」有 8 种散在 5 处，另有 5 句防串说明（「两条例外各管各的」「豁免不免锁」「豁免只免开 wt」「长期授权与闸分家」「长期授权不免修订卡」）；「归边不明就附带问一句」写了 4 遍；4 句补丁注脚；第 4、8 步细则只重复九步列表。
- 一个需求开 4 个 PR：#51 这一单开了 #50（spec）、#52（回填 Issue 号）、#53（实施）、#54（回填状态）。
- 维护本仓的规矩（仓名只当证据、不维护采用名单、新规则案例写这里）混在主文件，每个用流程的 agent 都要读。

**调研**（2026-10-04 打开核对，原文与链接见专项 spec 调研表）：Claude Code 压缩后每个技能只挂回前 5,000 token、不重读文件；Agent Skills best practices 把 SKILL.md 当目录，细则按任务读对应文件，引用只挂一层。坑：会话里读进来的参考文件压缩时不会被挂回，所以细则要在用的那一刻读，主文件里每条规矩至少留一句核心句。

**owner 拍板（2026-10-04 对话，卡片记录）**：方向是「解决叠床架屋，完整梳理 flow 思路，使之精简流畅」；骨架选「主线 + 卡片总表 + 豁免总表 + 细则用到才读」；行为变更「能改，但逐条给我点」，4 条候选点了 2（spec 头部回填随实施 PR）和 4（维护规矩移出主文件）。

**为什么用两张总表**：防串靠每行的「照样不免」列和「没点时」列一眼可查，不再靠补说明句；新增一种卡或一种免，只加一行。

**为什么回填随实施 PR**：spec 合并到实施前，spec 头部暂时没有 Issue 号，但 issue 正文锚着 spec 永久链接，单向可达；换来每个需求少开 2 个 PR。

**没采纳的两条**：「闸卡兼合并授权」（代码 PR 点了档位即同意审完合并）owner 没点，代码 PR 仍要合并卡；「摆闸卡前一律跑文档检查」owner 没点，仍按「交付物含文档改动」触发。

## R14 上线即关单（issue 状态标签备忘录·上线时分拣）

来源：#59 专项 spec `docs/specs/2026-10-06-close-on-release.md`（现状、调研表、D2–D8）。

- 落点：`references/issue-status-labels.md` 的〈上线时分拣〉节、阶段表「待验证」行、「受阻」行；`references/apply-to-project.md` §九（建标签命令、旧名改名报告、指针节模板）。

**现状（2026-10-06 实测 taoxi-system）**：
- #588（开放平台客户建档）9-29 21:36 写路由已发生产，剩下的验收项都要等某家合作方第一次真实调用；该单先后挂过「受阻」「待上线」，10-06 才改成「待验收」，「下次看」滚到 10-13。根子是定义重叠：「受阻（等外部条件）」和「待验收（等真实事件）」都套得上「等合作方来接」；「待上线（等发到生产）」没说给某家开通算不算上线。
- owner 原话：「凭据不应该作为收阻项，如果这样，那大部分开放平台的 issue 都会受阻，因为开发了不一定马上有人用」。
- 挂过「待验收」的 8 个单已全部关闭，其中 #588、#590、#532 是 10-06 当天用 owner 账号关的。

**调研**（2026-10-06 打开核对，原文与链接见专项 spec 调研表）：GitHub 默认 PR 合进默认分支就关联关单；Atlassian、GitLab 的惯例是发布后出问题开新 bug 单挂链接，不重开；Fowler 把「发布」与「部署」分开，上线 = 代码进生产；看板圈认为受阻 ≠ 排队等待；smoke test 在部署后立刻跑。反方：精益派加「Validated」列，证明有业务价值才算做完——未采纳。坑：这些都是团队协作工具的惯例，不是「一人 + 多 agent」场景的实测。

**owner 拍板（2026-10-06 对话，卡片记录）**：agent 先提三个机制（改写判据 / 挂受阻必写卡点 / 判断型换标签摆兜底卡），owner 没点，改提：「除非我们这个 issue 在测试环境验不了，必须去正式，否则待上线发布以后直接结束关单……发上线我们的 feat issue 的使命就结束了，后续有 bug 那也是 bug issue 的事情，别老是拖长单子」。要等外部方才能核的项选「不留单」（关单评论记一句核对时机）；规矩写进新 spec，09-29 旧 spec 不动；阶段名沿用 owner 原话「待验证」。

**为什么推翻 09-29「为观察期留单」**：当时「待验收」是给 3 个等观察期的单（#458、#490、#431）设的；实际用下来，等观察期、等外部方会让功能单一挂几周，而上线后出的问题本来就该开 bug 单，不需要原单守着。

**为什么用一句客观问句，不用兜底卡**：「这条现在能不能由我们自己动手验？」能机械地回答，agent 每次都会照着问；「拿不准就问用户」靠 agent 自己觉得拿不准，而研究显示模型认得出歧义、提问率却普遍不到 5%（arXiv 2605.25284），这种软规则几乎不触发。
