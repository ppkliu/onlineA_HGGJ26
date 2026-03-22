"""
DTL 劇本文字匯出工具
從 Dialogic timelines 目錄擷取台詞、NPC 對話、選項和註解，
輸出為結構化的 Markdown 文件。
"""

import argparse
import re
import sys
from datetime import datetime
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_TIMELINES_DIR = SCRIPT_DIR.parent / "timelines"
DEFAULT_OUTPUT_FILE = SCRIPT_DIR / "output" / "dialogue_export.md"

SKIP_PREFIXES = ("join ", "leave ", "jump ")

BRACKET_CMD_RE = re.compile(r"^\[(?:background|music|sound|wait|signal)\s")
DIALOGUE_RE = re.compile(r"^(\w+)\s*(?:\(([^)]*)\))?\s*:\s*(.+)$")
CHOICE_RE = re.compile(r"^-\s+(.+?)(?:\s*\|\s*\[if\s.+\])?\s*$")
CONDITION_RE = re.compile(r"^if\s+\{(.+?)\}.*:\s*$")
COMMENT_RE = re.compile(r"^#\s*(.*)")


def is_engine_command(line: str) -> bool:
    stripped = line.strip()
    if not stripped:
        return False
    if stripped.startswith("[") and BRACKET_CMD_RE.match(stripped):
        return True
    lower = stripped.lower()
    if any(lower.startswith(p) for p in SKIP_PREFIXES):
        return True
    return False


def parse_dtl_file(filepath: Path) -> list[str]:
    """Parse a single .dtl file and return formatted dialogue lines."""
    lines = filepath.read_text(encoding="utf-8").splitlines()
    result: list[str] = []
    prev_blank = False

    for raw_line in lines:
        stripped = raw_line.strip()

        if not stripped:
            if result and not prev_blank:
                result.append("")
                prev_blank = True
            continue

        if is_engine_command(stripped):
            continue

        indent = len(raw_line) - len(raw_line.lstrip())
        content = stripped

        if indent > 0 and content.startswith("[") and content.endswith("]"):
            continue

        if indent > 0 and any(content.lower().startswith(p) for p in SKIP_PREFIXES):
            continue

        comment_m = COMMENT_RE.match(content)
        if comment_m:
            text = comment_m.group(1).strip()
            if text and not BRACKET_CMD_RE.match(text):
                result.append(f"#### {text}")
                prev_blank = False
            continue

        cond_m = CONDITION_RE.match(content)
        if cond_m:
            var_name = cond_m.group(1)
            result.append(f"*[條件: {var_name}]*")
            prev_blank = False
            continue

        choice_m = CHOICE_RE.match(content)
        if choice_m:
            choice_text = choice_m.group(1).strip()
            result.append(f"- {choice_text}")
            prev_blank = False
            continue

        dial_m = DIALOGUE_RE.match(content)
        if dial_m:
            char_name = dial_m.group(1)
            expression = dial_m.group(2)
            text = dial_m.group(3).strip()
            if expression:
                result.append(f"**{char_name}** ({expression}): {text}")
            else:
                result.append(f"**{char_name}**: {text}")
            prev_blank = False
            continue

        prev_blank = False

    while result and result[-1] == "":
        result.pop()

    return result


def build_markdown(timelines_dir: Path) -> str:
    """Scan timelines directory and build the full Markdown export."""
    parts: list[str] = []

    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    parts.append("# 劇本文字匯出")
    parts.append("")
    parts.append(f"> 產生時間：{now_str}")
    parts.append(f"> 來源目錄：{timelines_dir}")
    parts.append("")

    folders = sorted(
        [d for d in timelines_dir.iterdir() if d.is_dir()],
        key=lambda d: d.name,
    )

    if not folders:
        parts.append("*（未找到任何章節資料夾）*")
        return "\n".join(parts)

    stats = {"folders": 0, "files": 0, "lines": 0}

    for folder in folders:
        dtl_files = sorted(folder.glob("*.dtl"), key=lambda f: f.name)
        if not dtl_files:
            continue

        parts.append("---")
        parts.append("")
        parts.append(f"## {folder.name}")
        parts.append("")
        stats["folders"] += 1

        for dtl_file in dtl_files:
            dialogue_lines = parse_dtl_file(dtl_file)
            if not dialogue_lines:
                continue

            parts.append(f"### {dtl_file.name}")
            parts.append("")
            parts.extend(dialogue_lines)
            parts.append("")
            stats["files"] += 1
            stats["lines"] += len([l for l in dialogue_lines if l.strip()])

    parts.append("---")
    parts.append("")
    parts.append(
        f"> 統計：{stats['folders']} 個章節 / "
        f"{stats['files']} 個檔案 / "
        f"{stats['lines']} 行文字內容"
    )
    parts.append("")

    return "\n".join(parts)


def main():
    parser = argparse.ArgumentParser(
        description="DTL 劇本文字匯出工具 — 擷取台詞、對話、選項和註解"
    )
    parser.add_argument(
        "-i", "--input",
        type=Path,
        default=DEFAULT_TIMELINES_DIR,
        help=f"timelines 目錄路徑 (預設: {DEFAULT_TIMELINES_DIR})",
    )
    parser.add_argument(
        "-o", "--output",
        type=Path,
        default=DEFAULT_OUTPUT_FILE,
        help=f"輸出檔案路徑 (預設: {DEFAULT_OUTPUT_FILE})",
    )
    parser.add_argument(
        "--console",
        action="store_true",
        help="直接輸出到終端而不寫入檔案",
    )
    args = parser.parse_args()

    timelines_dir: Path = args.input.resolve()
    if not timelines_dir.is_dir():
        print(f"錯誤：找不到 timelines 目錄: {timelines_dir}", file=sys.stderr)
        sys.exit(1)

    markdown = build_markdown(timelines_dir)

    if args.console:
        print(markdown)
    else:
        output_path: Path = args.output.resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(markdown, encoding="utf-8")
        print(f"匯出完成：{output_path}")


if __name__ == "__main__":
    main()
