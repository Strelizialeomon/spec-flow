#!/usr/bin/env bash
# spec-flow 文档检查入口：SKILL.md 正文字数、警示符个数、references 路径是否存在、
# README 双语是否同步（节标记一一对应、references 文件两份都点到）、采用契约两侧是否对应。
# 每项一行结果，末行「绿 / 红」；退出码 0 = 绿，1 = 红。依据见 references/rationale.md R10、R17、R19。

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
    # ── 采用契约（依据 R19）：SKILL.md 中央登记 ↔ apply-to-project.md §十 登记表，两侧必须一一对应 ──
    # 只认登记区：SKILL.md 参考表里带「选修」的行 + apply-to-project.md §十 的 `#### ` 表；
    # 围栏代码块里的示例（采用口径模板等）一律跳过，历史 spec 不在扫描范围内。
    def unfenced(text):
        out, fence = [], None
        for line in text.splitlines():
            st = line.lstrip()
            if fence:
                if st.startswith(fence):
                    fence = None
                continue
            if st.startswith("```") or st.startswith("~~~"):
                fence = st[:3]
                continue
            out.append(line)
        return out

    ROW_RE = re.compile(r"\|\s*`(references/[^`]+\.md)`\s*\|(.*)\|\s*$")
    MOD_RE = re.compile(r"采用走 `([a-z0-9-]+)`")
    NOADOPT = ("仅本次按需", "仅支持本次按需读取")   # 「不支持项目级采用」的两种合法措辞都认
    FIELDS = {"修饰词", "语义变体", "项目入口", "项目资产", "执行时点", "验收方式", "幂等规则", "旧物处置"}
    MEMO_FIELDS = [("默认",), ("本次按需读取",), ("项目级采用", "项目级持久采用"),
                   ("项目入口",), ("执行时点",), ("验收",)]
    problems, rows_to_mod, memo_rows, listed = [], {}, {}, set()
    for line in unfenced(body):
        m = ROW_RE.match(line)
        if not m:
            continue
        path, rest = m.group(1), m.group(2)
        listed.add(path)
        if "选修" not in rest:
            continue
        memo_rows[path] = rest
        mod = MOD_RE.search(rest)
        if mod:
            if mod.group(1) in rows_to_mod:
                problems.append(f"修饰词 `{mod.group(1)}` 被两行同时登记：{rows_to_mod[mod.group(1)]}、{path}")
            rows_to_mod[mod.group(1)] = path
        elif not any(k in rest for k in NOADOPT):
            problems.append(f"{path}：既没有「采用走 `<modifier>`」也没写「仅本次按需」")
        if "默认关闭" not in rest:
            problems.append(f"{path}：行内缺「默认关闭」")
        if "声明已采用" not in rest and not any(k in rest for k in NOADOPT):
            problems.append(f"{path}：行内缺读取条件——项目已声明采用（或「仅本次按需」）")

    # 「未登记 = 未生效」：references/ 下每个 .md 都要在参考表里有行；带「采用口径」的必须是选修行
    try:
        ref_md = sorted(f for f in os.listdir("references") if f.endswith(".md"))
    except OSError:
        ref_md = []
    memo_files = {}
    for f in ref_md:
        rel = "references/" + f
        if rel not in listed:
            problems.append(f"{rel} 不在 SKILL.md 参考表里（新增参考文件必须登记）")
        try:
            t = "\n".join(unfenced(open(rel, encoding="utf-8", newline="").read()))
        except OSError:                     # 围栏里的「采用口径」模板不算（如 apply-to-project.md §十）
            continue
        if "## 采用口径" in t:
            memo_files[rel] = t
            if rel not in memo_rows:
                problems.append(f"{rel} 有「采用口径」区块、参考表里却没有它的选修行")
    for rel in sorted(memo_rows):
        if rel not in memo_files and exists_exact(rel):
            problems.append(f"{rel} 缺「采用口径」区块")

    try:
        ap_text = open("references/apply-to-project.md", encoding="utf-8", newline="").read()
    except OSError:
        ap_text = ""
        problems.append("references/apply-to-project.md 读不到")
    sec = ap_text[ap_text.index("## 十、采用契约"):] if "## 十、采用契约" in ap_text else ""
    if not sec:
        problems.append("apply-to-project.md 没有 §十 采用契约")
    reg_mods, cur, in_table, table_done = {}, None, False, False
    for line in unfenced(sec):
        s = line.strip()
        h = re.fullmatch(r"#### `([a-z0-9-]+)`", s)
        if h:
            cur = h.group(1)
            if cur in reg_mods:
                problems.append(f"§十 出现两张同名登记表：`{cur}`（只算后一张会漏检前一张）")
            reg_mods[cur] = {}
            in_table, table_done = False, False
            continue
        if re.match(r"#{1,3} \S", s):      # 更上层标题 = 离开登记区
            cur, in_table, table_done = None, False, False
            continue
        if cur is None:
            continue
        if s.startswith("|"):
            if table_done:                  # 表已结束又冒出来的表行 = 表外，不算字段
                continue
            cells = [c.strip() for c in s.strip("|").split("|")]
            if len(cells) == 2 and cells[0] and not set(cells[0]) <= set("-: "):
                if cells[0] in reg_mods[cur]:
                    problems.append(f"修饰词 `{cur}` 登记表字段重复：{cells[0]}")
                reg_mods[cur][cells[0]] = cells[1]
            in_table = True
            continue
        if s == "":
            continue
        if in_table:
            table_done = True
        in_table = False
    for mod, got in sorted(reg_mods.items()):
        miss = FIELDS - set(got)
        if miss:
            problems.append(f"修饰词 `{mod}` 登记表缺字段：{'、'.join(sorted(miss))}")
        elif got.get("修饰词") != f"`{mod}`":
            problems.append(f"修饰词 `{mod}` 的登记表里「修饰词」行写的是「{got.get('修饰词', '')}」——表体与标题对不上")
    for mod in sorted(set(rows_to_mod) - set(reg_mods)):
        problems.append(f"`{mod}` 在 SKILL.md 登记、§十 没有登记表")
    for mod in sorted(set(reg_mods) - set(rows_to_mod)):
        problems.append(f"`{mod}` 在 §十 有登记表、SKILL.md 没登记")
    if not rows_to_mod and not reg_mods:
        problems.append("参考表与 §十 一个选修备忘录 / 登记表都没有（契约被掏空？）")
    for rel, t in sorted(memo_files.items()):
        block = t[t.index("## 采用口径"):]
        nxt = block.find("\n## ", 3)
        if nxt != -1:
            block = block[:nxt]
        miss = ["/".join(f) for f in MEMO_FIELDS if not any(k in block for k in f)]
        if miss:
            problems.append(f"{rel} 采用口径缺：{'、'.join(miss)}")
        rest = memo_rows.get(rel)
        mod = MOD_RE.search(rest) if rest else None
        if mod and f"`{mod.group(1)}`" not in block:
            problems.append(f"{rel} 采用口径没写自己的修饰词 `{mod.group(1)}`——备忘录与登记对不上")
    report(not problems, f"采用契约：{len(memo_rows)} 个选修备忘录 / {len(reg_mods)} 张登记表" +
           ("，两侧一一对应、字段齐全" if not problems else "：" + "；".join(problems)))

except Exception as e:  # 跑崩也算红，原因写出来
    report(False, f"检查跑崩了：{e!r}")

print("红" if red else "绿")
sys.exit(1 if red else 0)
PY
