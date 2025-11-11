import argparse
import os
from pathlib import Path

BASE = Path(__file__).resolve().parents[2]
TEMPLATES_DIR = BASE / "templates" / "prompt"
ARTIFACTS_DIR = BASE / "artifacts"

PROMPT_FILES = [
    "01_requirement_decomposition.md",
    "02_sql_generation.md",
    "03_mock_and_selftest.md",
    "04_testcases_and_assertions.md",
    "05_monitoring_rules.md",
]

def ensure_dirs():
    (ARTIFACTS_DIR / "requirements").mkdir(parents=True, exist_ok=True)
    (ARTIFACTS_DIR / "sql").mkdir(parents=True, exist_ok=True)
    (ARTIFACTS_DIR / "tests" / "report").mkdir(parents=True, exist_ok=True)
    (ARTIFACTS_DIR / "monitoring").mkdir(parents=True, exist_ok=True)

def cmd_init(args):
    ensure_dirs()
    (ARTIFACTS_DIR / "requirements" / "requirement.md").write_text("# 需求说明\n\n", encoding="utf-8")
    print(f"Initialized artifacts at: {ARTIFACTS_DIR}")

def cmd_gen_templates(args):
    out_dir = BASE / "current_prompts"
    out_dir.mkdir(parents=True, exist_ok=True)
    for name in PROMPT_FILES:
        src = TEMPLATES_DIR / name
        dst = out_dir / name
        dst.write_text(src.read_text(encoding="utf-8"), encoding="utf-8")
    print(f"Copied prompt templates to: {out_dir}")

def main():
    parser = argparse.ArgumentParser(description="AI-assisted Data Engineering Helper")
    sub = parser.add_subparsers(required=True)

    p_init = sub.add_parser("init", help="Initialize artifacts directories and seed files")
    p_init.set_defaults(func=cmd_init)

    p_tpl = sub.add_parser("gen-templates", help="Copy prompt templates to current_prompts/")
    p_tpl.set_defaults(func=cmd_gen_templates)

    args = parser.parse_args()
    args.func(args)

if __name__ == "__main__":
    main()


