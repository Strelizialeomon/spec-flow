#!/usr/bin/env bash
# spec-flow 文档检查入口（体量护栏）：SKILL.md 正文字数、警示符个数、references 路径是否存在。
# 每项一行结果，末行「绿 / 红」；退出码 0 = 绿，1 = 红。依据见 references/rationale.md R10。

BUDGET_CHARS=9000   # SKILL.md 正文字符数上限（口径：frontmatter 结束行之后到文件末，每行计换行）
MAX_ALERTS=3        # SKILL.md 正文 ⚠️ + ⛔ 个数上限

cd "$(dirname "$0")/.." || { echo "[红] 进不了仓根目录"; echo "红"; exit 1; }

if ! command -v python3 >/dev/null 2>&1; then
  echo "[红] 找不到 python3，检查跑不起来"
  echo "红"
  exit 1
fi

python3 - "$BUDGET_CHARS" "$MAX_ALERTS" <<'PY'
import os, re, sys

budget, max_alerts = int(sys.argv[1]), int(sys.argv[2])
red = False

def report(ok, msg):
    global red
    red = red or not ok
    print(("[绿] " if ok else "[红] ") + msg)

try:
    text = open("SKILL.md", encoding="utf-8").read()
    lines = text.splitlines(keepends=True)
    # frontmatter = 第一行 --- 到下一行 ---；正文 = 结束行之后的全部字符
    if not lines or lines[0].strip() != "---":
        raise ValueError("SKILL.md 开头没有 frontmatter")
    end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    body = "".join(lines[end + 1:])

    n = len(body)
    report(n <= budget, f"正文字数 {n:,} / 预算 {budget:,}" + ("" if n <= budget else
           " —— 新增的案例 / 统计 / 来龙去脉进 references/rationale.md，规则旁只留一句理由；依据见 rationale R10"))

    alerts = body.count("⚠") + body.count("⛔")
    report(alerts <= max_alerts, f"正文警示符（⚠️ + ⛔）{alerts} / 上限 {max_alerts}")

    refs = sorted(set(re.findall(r"references/[A-Za-z0-9._-]+\.md", text)))
    missing = [r for r in refs if not os.path.isfile(r)]
    report(not missing, f"references 路径 {len(refs)} 个" +
           ("，均存在" if not missing else "，不存在：" + "、".join(missing)))
except Exception as e:  # 跑崩也算红，原因写出来
    report(False, f"检查跑崩了：{e!r}")

print("红" if red else "绿")
sys.exit(1 if red else 0)
PY
