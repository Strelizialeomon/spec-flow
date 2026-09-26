# spec-flow

自建的流程规矩：复杂活（要设计、动多个端、值得留可回溯依据的）走**两段流程**（方案期 + 实施期，共用一道合并闸）。

两段是哪两段、每步怎么走，**以 `SKILL.md` 为准**——这份 README 不列顺序，免得两处各说各话。

## 这个仓为什么存在

spec-flow 以前**活在 git 之外**：三处副本、零历史。2026-09-16 追一条规矩的
来历时，这个洞露出来了——`~/.claude` 不是 git 仓，"谁写的、什么时候写的"
全追不出来，只能翻会话记录倒推，推到 2026-08-24 就到头了。

现在它是个正常的 git 仓：**谁改了它，`git log` 一句话就能看见。**

## 真身在这里，别改别处

**这份 `~/code/spec-flow` 是唯一真身。** 三处 skill 目录都是指向它的符号链接：

| 位置 | 谁读 |
|---|---|
| `~/.claude/skills/spec-flow` | Claude Code |
| `~/.agents/skills/spec-flow` | 经由上面那条链过去 |
| `~/.kimi-code/skills/spec-flow` | kimi |

**要改就改这里，改完三处一起生效。** 反过来说：三处都是软链，改哪都是改真身，不存在
「有人偷偷改了某一份副本」——真出问题只会是一种：某处的软链被换成了真目录，从此和这里脱钩。
发现就删掉那个真目录、把软链建回去。

## 目录

```
SKILL.md                     流程正文
references/split-large-spec.md   拆大 spec 的备忘录（非流程）
references/adr-decision-records.md  ADR 可选采用的备忘录（非流程，默认不启用）
references/adoption-model.md     采纳模型（三层）的备忘录（非流程）
references/documentation-lifecycle.md  文档生命周期的可选备忘录（非流程）
references/apply-to-project.md   应用到项目的模板与细则（用户触发，非流程）
references/rationale.md          依据档案：规则背后的案例、统计、来龙去脉（非流程）
scripts/check-docs.sh            文档检查入口：SKILL.md 体量护栏（正文字数、警示符、references 路径）
```

## 历史说明

前两个提交是**事后重建**的，不是当时真实发生的提交：

| 提交 | 对应时间 | 怎么来的 |
|---|---|---|
| 1 | 2026-09-10 | 从 `~/.kimi-code/skills/spec-flow/.backup/` 里捞回的最早一份真实副本 |
| 2 | 2026-09-15 | 建仓当天三处副本的实际内容 |

再往前的历史找不回来了——那段时期它压根没有版本记录。从提交 3 开始才是真实记录。
