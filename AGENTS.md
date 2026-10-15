# spec-flow 仓的维护规矩

本仓就是 spec-flow 的真身（本机怎么接线的说明见 `docs/maintainer-notes.md`）。改 `SKILL.md`、`references/` 或任一 README 时：

1. 仓名只准当某条规矩的一次性证据，不攒成可追加的登记表——仓自己改了规矩，没人会回来改这里，登记表只会越挂越旧（依据：rationale R9）。
2. 本 skill 不维护采用名单，也不登记哪个仓禁了哪一档审核；这些问那个仓自己的指令，也不去猜。
3. 新增规则时，案例 / 统计 / 来龙去脉写进 `references/rationale.md`、编新 R 号；主文件只留一句理由和「（依据：rationale Rn）」指针。
4. 改完 `SKILL.md` 跑 `scripts/check-docs.sh`，预算见脚本顶部（依据：rationale R10）。
5. 改任一份 README（`README.md` / `README.zh-CN.md`）必须同步另一份——节标记 `<!-- s:xxx -->` 一一对应、`references/` 文件两份都点到，改完跑 `scripts/check-docs.sh` 验证（依据：rationale R17）。
