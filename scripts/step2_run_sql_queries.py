"""
Step 2 - Run every business question in sql/customer_analysis_queries_sqlite.sql against the
SQLite database and save the results to results/sql_query_results.md.

Run:  python scripts/step2_run_sql_queries.py
"""
from pathlib import Path
import re
import sqlite3

import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "data" / "customer_behavior.db"
SQL_FILE = ROOT / "sql" / "customer_analysis_queries_sqlite.sql"
OUT = ROOT / "results" / "sql_query_results.md"


def load_queries(path: Path) -> list[tuple[str, str]]:
    """Split the .sql file into (title, query) pairs using the '-- Qn:' headers."""
    text = path.read_text(encoding="utf-8")
    parts = re.split(r"^-- (Q\d+:.*)$", text, flags=re.MULTILINE)
    queries = []
    for title, body in zip(parts[1::2], parts[2::2]):
        sql = "\n".join(l for l in body.splitlines() if not l.strip().startswith("--")).strip()
        if sql:
            queries.append((title.strip(), sql))
    return queries


def main() -> None:
    if not DB.exists():
        raise SystemExit("Database not found - run `python scripts/step1_clean_data.py` first.")

    sections = ["# SQL Results\n", "_Output of `scripts/step2_run_sql_queries.py`._\n"]
    with sqlite3.connect(DB) as conn:
        for title, sql in load_queries(SQL_FILE):
            result = pd.read_sql_query(sql, conn)
            print(f"\n{title}\n{result.to_string(index=False)}")
            sections.append(f"## {title}\n\n{result.to_markdown(index=False)}\n")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(sections), encoding="utf-8")
    print(f"\nSaved -> {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
