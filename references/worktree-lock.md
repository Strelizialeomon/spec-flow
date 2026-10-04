# 认领 issue 与锁（认领、撞锁、放锁时读）

> 主文件 `SKILL.md` 只留核心句；本文件是展开，走到这一步时读。

锁由 git 保管，不靠登记、不靠吱声。

- **命名 = 锁**：分支和 worktree 目录同名 `issue-<N>`，纯号、无 slug、无前缀。同一 `.git` 里分支名唯一、已被检出的分支不许再检出——git 强制（依据：rationale R6）。认领就是开 worktree：开得成 = 没人做；被拒 = 有人在做。
- **认领**：`git fetch origin --prune` 后 `git worktree add <wt根>/issue-<N> -b issue-<N> origin/main`（wt 根项目自定，如 `.claude/worktrees/`；从 origin/main 建，本地 main 可能落后）。想早知道可先 `git worktree list | grep issue-<N>`——可选，锁不靠它。⚠️ 别拿 issue `open` 当「没人认领」：open 同时表示待做和在做（依据：rationale R7）——只信锁。
- **撞锁 = 停**：`fatal: a branch named 'issue-<N>' already exists` = 有人领过。`git worktree list` 找到对方工作区路径：目录还在 → 人在做，去读该 issue 的评论定等 / 让；目录没了 → 对方已不在，`git worktree prune` 清掉残留登记后接手：`git worktree add <wt根>/issue-<N> issue-<N>`（不带 -b 复用旧分支 = 接着对方的提交干；想推倒重来就先 `git branch -D issue-<N>` 再带 -b 新建）。
- **放锁**：PR 合并后 `git worktree remove <wt根>/issue-<N>` + `git branch -d issue-<N>`（`-d` 认的是 fetch 后的 origin/main，先 `git fetch origin`；远端 squash 合并时 `-d` 照样以 not fully merged 拒删——换 `-D`）（依据：rationale R8）。不放 = issue 重开时永远撞锁。
- **进 worktree 第一件事重新取基准**（`pwd`）：编辑工具用的绝对路径不跟 cwd 走，照会话前半段记下的主仓路径写，改的是主仓、还没报错。快信号：新写的测试报 `no tests to run`、新符号 grep 不到、worktree 里 `git status` 是空的。
- **边界**：锁只挡同号认领——不同 issue 改同一堆文件拦不住（那是拆 spec 时「独占文件」规矩管的，见 `references/split-large-spec.md`）；跨机 / 跨 clone 不共享 `.git`，无锁；`git worktree add --force` 能强拆——本机制只防守规矩的人犯错，不防故意绕过。没有 issue 号的活：wt 照开（见主文件「工作区与锁」节）但无锁可领，命名随意（惯例 `<type>/<slug>`）。
