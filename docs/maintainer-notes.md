# 本仓自己的说明（维护者视角）

> 对外读者不用读这份。它记的是「这份检出怎么接的线」「历史里哪段是重建的」——
> 以前写在 `README.md` 里，2026-10-15 开源准备时挪出来（依据：rationale R17）。

## 真身在这里

**`~/code/spec-flow`（或任何你 clone 的地方）是唯一真身。** 别处的 skill 目录都是软链：

```bash
git clone https://github.com/Strelizialeomon/spec-flow.git ~/code/spec-flow
ln -s ~/code/spec-flow ~/.claude/skills/spec-flow                  # Claude Code
ln -s ~/.claude/skills/spec-flow ~/.agents/skills/spec-flow        # 共享 skills 目录，走上面那条链
```

**要改就改真身，改完各条链一起生效。** 反过来，链上那几个目录都是软链，改哪都是改真身——
不存在「有人偷偷改了某一份副本」。真出问题只会是一种：某处的软链被换成了真目录，从此和真身脱钩。
发现就删掉那个真目录、把软链建回去。

⚠️ **别把上面这块扩成「哪台机器接了哪条链」的登记表**——本仓最容易烂的就是这种东西。
2026-10-15 实测：旧 `README.md` 里那张表已经烂了一条（`~/.kimi-code/skills/spec-flow` 指向的目录
在本机整个不存在，kimi 早卸了），而当天真在用的 `~/.codex/skills` 从没写进去过。
链的实际状态当场看（`readlink` / `ls -l`），别信文档（依据：rationale R17、R9）。

## 历史说明

前两个提交是**事后重建**的，不是当时真实发生的提交：

| 提交 | 对应时间 | 怎么来的 |
|---|---|---|
| 1 | 2026-09-10 | 从 `~/.kimi-code/skills/spec-flow/.backup/` 里捞回的最早一份真实副本 |
| 2 | 2026-09-15 | 建仓当天三处副本的实际内容 |

再往前的历史找不回来了——那段时期它压根没有版本记录。从提交 3 开始才是真实记录。

spec-flow 以前**活在 git 之外**：三处副本、零历史。2026-09-16 追一条规矩的来历时，这个洞露出来了——
`~/.claude` 不是 git 仓，「谁写的、什么时候写的」全追不出来，只能翻会话记录倒推，推到 2026-08-24 就到头了。
现在它是个正常的 git 仓：谁改了它，`git log` 一句话就能看见。
