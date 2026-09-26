#!/usr/bin/env bash
# spec-flow 文档检查入口（体量护栏）：SKILL.md 正文字数、警示符个数、references 路径是否存在。
# 每项一行结果，末行「绿 / 红」；退出码 0 = 绿，1 = 红。依据见 references/rationale.md R10。

BUDGET_CHARS=9000   # SKILL.md 正文字符数上限（口径：frontmatter 结束行之后到文件末，每行计换行）
MAX_ALERTS=3        # SKILL.md 正文 ⚠️ + ⛔ 个数上限

CDPATH= cd -- "$(dirname -- "$0")/.." || { echo "[红] 进不了仓根目录"; echo "红"; exit 1; }

if ! command -v python3 >/dev/null 2>&1; then
  echo "[红] 找不到 python3，检查跑不起来"
  echo "红"
  exit 1
fi

PYTHONIOENCODING=utf-8 python3 - "$BUDGET_CHARS" "$MAX_ALERTS" <<'PY'
import os, re, sys

budget, max_alerts = int(sys.argv[1]), int(sys.argv[2])
red = False

def report(ok, msg):
    global red
    red = red or not ok
    print(("[绿] " if ok else "[红] ") + msg)

try:
    # newline="" 保留原换行符（CRLF 计 2 字，与 wc -m 同口径）
    text = open("SKILL.md", encoding="utf-8", newline="").read()
    lines = text.splitlines(keepends=True)
    # frontmatter = 第一行 --- 到下一行 ---，中间只许 YAML 键行 / 缩进续行 / 空行；
    # 碰到别的行还没见到结束行 = frontmatter 坏了（防止把正文里的水平线当结束行）
    if not lines or lines[0].rstrip("\r\n") != "---":
        raise ValueError("SKILL.md 开头没有 frontmatter")
    end = None
    for i in range(1, len(lines)):
        s = lines[i].rstrip("\r\n")
        if s == "---":
            end = i
            break
        if not (s.strip() == "" or re.match(r"[A-Za-z0-9_-]+\s*:", s) or s[:1] in " \t"):
            break
    if end is None:
        raise ValueError(f"frontmatter 没有结束行 ---（第 {i + 1} 行不像 YAML）")
    body = "".join(lines[end + 1:])

    n = len(body)
    report(n <= budget, f"正文字数 {n:,} / 预算 {budget:,}" + ("" if n <= budget else
           " —— 新增的案例 / 统计 / 来龙去脉进 references/rationale.md，规则旁只留一句理由；依据见 rationale R10"))

    alerts = body.count("⚠") + body.count("⛔")
    report(alerts <= max_alerts, f"正文警示符（⚠️ + ⛔）{alerts} / 上限 {max_alerts}")

    # 只认本仓相对路径：前面紧挨 / 或字母数字的（外仓 URL 等）不算；路径可含子目录、非 ASCII
    refs = sorted(set(re.findall(r"(?<![/\w.-])references/[^\s`'\"()<>\[\]|，。；：、）」]+?\.md", text)))

    def exists_exact(path):  # 逐级比对真实文件名，大小写不敏感的文件系统上也不放过写错大小写
        cur = "."
        for part in path.split("/"):
            if not os.path.isdir(cur) or part not in os.listdir(cur):
                return False
            cur = os.path.join(cur, part)
        return os.path.isfile(cur)

    missing = [r for r in refs if not exists_exact(r)]
    report(not missing, f"references 路径 {len(refs)} 个" +
           ("，均存在" if not missing else "，不存在：" + "、".join(missing)))
except Exception as e:  # 跑崩也算红，原因写出来
    report(False, f"检查跑崩了：{e!r}")

print("红" if red else "绿")
sys.exit(1 if red else 0)
PY
