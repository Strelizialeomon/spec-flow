#!/usr/bin/env bash
# spec-flow 文档检查入口：SKILL.md 正文字数、警示符个数、references 路径是否存在、
# README 双语是否同步（节标记一一对应、references 文件两份都点到）。
# 每项一行结果，末行「绿 / 红」；退出码 0 = 绿，1 = 红。依据见 references/rationale.md R10、R17。

BUDGET_CHARS=5000   # SKILL.md 正文字符数上限（口径：frontmatter 结束行之后到文件末，每行计换行）；约 4,300 token（2026-10-04 实测每字 0.86 token），压缩后整份留在前 5,000 token 内；依据 R10
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

    # ── README 双语同步（依据 R17）────────────────────────────────────────
    # 只守结构：两份 README 的节标记 <!-- s:xxx --> 必须一一对应、顺序一致，且每个标记紧贴着
    # 一个 ## 标题（标记搬家 = 红）；references/ 下每个文件两份 README 都要点到、点到的路径要真存在。
    # 同一节里改了一句只改一份，机器看不出来——那部分靠 AGENTS.md 第 5 条。
    def sections(text):
        """扫出 [(节标记, 紧随的标题, 标题行号)]；围栏代码块（``` 与 ~~~）里的行一律不算，
        标记与标题之间只许有空行，标记后跟了别的东西 = 标记没贴着标题。"""
        out, fence, pending, pend_line = [], None, None, 0
        for i, line in enumerate(text.splitlines(), 1):
            stripped = line.lstrip()
            if fence:
                if stripped.startswith(fence):
                    fence = None
                continue
            if stripped.startswith("```") or stripped.startswith("~~~"):
                fence = stripped[:3]        # 只用同种符号闭合，且认开头这三个字符
                continue
            m = re.fullmatch(r"<!--\s*s:([a-z0-9-]+)\s*-->", line.strip())
            if m:
                if pending is not None:     # 上一个标记还没配上标题就来了新标记 = 它没贴着标题
                    out.append((pending, None, pend_line))
                pending, pend_line = m.group(1), i
                continue
            if re.match(r"##\s+\S", line):
                out.append((pending, line, i))
                pending = None
            elif stripped:                  # 非空、又不是标题 = 标记和标题之间夹了别的东西
                if pending is not None:
                    out.append((pending, None, pend_line))
                    pending = None
        if pending is not None:             # 标记挂在文件末尾，后面没有标题
            out.append((pending, None, pend_line))
        return out

    def mentions(text, path):               # 路径被换行 / 空格拆开也算点到（免得误报红）
        return path in text or re.sub(r"\s+", "", path) in re.sub(r"\s+", "", text)

    readmes, secs = {}, {}
    for name in ("README.md", "README.zh-CN.md"):
        try:
            content = open(name, encoding="utf-8", newline="").read()
        except OSError:
            report(False, f"{name} 读不到（双语 README 少一份）")
            readmes[name] = None
            continue
        readmes[name] = content
        secs[name] = sections(content)

    if None not in readmes.values():
        # 没配到标记的标题用占位符进序列（真值是不可哈希的 None，直接比会炸；缺标记由下面那项点名）
        ma = [m or "（无标记）" for m, _, _ in secs["README.md"]]
        mb = [m or "（无标记）" for m, _, _ in secs["README.zh-CN.md"]]
        na = sum(1 for x in ma if x != "（无标记）")
        nb = sum(1 for x in mb if x != "（无标记）")
        only_a = [x for x in ma if x not in mb]
        only_b = [x for x in mb if x not in ma]
        diff = []
        if only_a:
            diff.append("仅 README.md 有：" + "、".join(only_a))
        if only_b:
            diff.append("仅 README.zh-CN.md 有：" + "、".join(only_b))
        if not diff and ma != mb:
            diff.append("顺序不一致")
        report(not diff, f"双语节标记 {na} / {nb} 节" +
               ("，一一对应" if not diff else "：" + "；".join(diff)))

        loose = [f"{n}:{ln} 标记 s:{m} 没贴着 ## 标题" for n in secs for m, h, ln in secs[n] if m and not h]
        loose += [f"{n}:{ln} 标题「{h.strip()}」没有节标记" for n in secs for m, h, ln in secs[n] if h and not m]
        report(not loose, "每个节标记都贴着一个 ## 标题" if not loose else "；".join(loose))

        try:
            ref_files = sorted(f for f in os.listdir("references") if f.endswith(".md"))
        except OSError:
            ref_files = None
        report(ref_files is not None, f"references 目录下 {len(ref_files)} 个 .md" if ref_files is not None
               else "references 目录读不到——这项检查失效，不是绿")
        if ref_files is not None:
            unlisted = ["references/" + f for f in ref_files
                        if not all(mentions(readmes[n], "references/" + f) for n in readmes)]
            report(not unlisted, f"references 文件 {len(ref_files)} 个，两份 README 都点到" if not unlisted
                   else "两份 README 没都点到：" + "、".join(unlisted))
            bogus = sorted({p for n in readmes
                            for p in re.findall(r"references/[^\s`'\"()<>\[\]|，。；：、）]+?\.md", readmes[n])
                            if not exists_exact(p)})
            report(not bogus, "README 里点到的 references 路径都存在" if not bogus
                   else "README 里点到的路径不存在：" + "、".join(bogus))
except Exception as e:  # 跑崩也算红，原因写出来
    report(False, f"检查跑崩了：{e!r}")

print("红" if red else "绿")
sys.exit(1 if red else 0)
PY
